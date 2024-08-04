//
//  CameraController.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-04-20.
//
//

import Foundation
import AmazonChimeSDK
import AVFoundation
import CoreImage
import UIKit


// MARK: CameraController

/// The Controller for accessing the camera directly.
///
/// This contains the application logic for capturing photos from the device camera.
///
class CameraController: NSObject, AVCapturePhotoCaptureDelegate {

    // MARK: - Life cycle methods

    override init() {
        super.init()

        sessionQueue = DispatchQueue(label: "session queue")
        captureDevice = availableCaptureDevices.first ?? AVCaptureDevice.default(for: .video)
    }

    // MARK: - Properties

    var isRunning: Bool {
        captureSession.isRunning
    }

    var isUsingFrontCaptureDevices: Bool {
        guard let captureDevice = captureDevice else { return false }
        return frontCaptureDevices.contains(captureDevice)
    }

    var isUsingBackCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return backCaptureDevices.contains(captureDevice)
    }

    private let logger = ConsoleLogger(name: "CameraController")

    private let captureSession = AVCaptureSession()

    private var isCaptureSessionConfigured = false

    private var deviceInput: AVCaptureDeviceInput?

    private var photoOutput: AVCapturePhotoOutput?

    private var sessionQueue: DispatchQueue!

    private var allCaptureDevices: [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(
                deviceTypes: [
                    .builtInTrueDepthCamera,
                    .builtInDualCamera,
                    .builtInDualWideCamera,
                    .builtInWideAngleCamera,
                    .builtInDualWideCamera
                ],
                mediaType: .video,
                position: .unspecified)
            .devices
    }

    private var frontCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices.filter { $0.position == .front }
    }

    private var backCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices.filter { $0.position == .back }
    }

    private var captureDevices: [AVCaptureDevice] {
        var devices = [AVCaptureDevice]()
        if let backDevice = backCaptureDevices.first { devices += [backDevice] }
        if let frontDevice = frontCaptureDevices.first { devices += [frontDevice] }
        return devices
    }

    private var availableCaptureDevices: [AVCaptureDevice] {
        captureDevices.filter { $0.isConnected && !$0.isSuspended }
    }

    private var captureDevice: AVCaptureDevice? {
        didSet {
            guard let captureDevice = captureDevice else { return }
            logger.info(msg: "Using capture device: \(captureDevice.localizedName)")
            sessionQueue.async { self.updateSessionForCaptureDevice(captureDevice) }
        }
    }

    private var deviceOrientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }

    private var continuations: [CheckedContinuation<AVCapturePhoto, Error>] = []

    // MARK: - Methods

    func start() {
        let authorized = checkAuthorization()
        guard authorized else {
            logger.error(msg: "Camera access was not authorized.")
            return
        }

        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                sessionQueue.async { [self] in self.captureSession.startRunning() }
            }
            return
        }

        sessionQueue.async { [self] in
            self.configureCaptureSession { success in
                guard success else { return }
                self.captureSession.startRunning()
            }
        }
    }

    func stop() {
        guard isCaptureSessionConfigured else { return }

        if captureSession.isRunning {
            sessionQueue.async { self.captureSession.stopRunning() }
        }
    }

    func switchCaptureDevice() {
        if let captureDevice = captureDevice, let index = availableCaptureDevices.firstIndex(of: captureDevice) {
            let nextIndex = (index + 1) % availableCaptureDevices.count
            self.captureDevice = availableCaptureDevices[nextIndex]
        } else {
            self.captureDevice = AVCaptureDevice.default(for: .video)
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            logger.error(msg: "Error capturing photo: \(error.localizedDescription)")
        }

        for continuation in continuations {
            if let error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume(returning: photo)
            }
        }
        continuations = []
    }

    func takePhoto() async throws -> AVCapturePhoto {
        guard let photoOutput = self.photoOutput else {
            throw CameraError.unexpectedError
        }
        guard photoOutput.availablePhotoCodecTypes.contains(.jpeg) else {
            throw CameraError.codecUnavailable
        }

        sessionQueue.async {
            let photoSettings = AVCapturePhotoSettings(
                format: [
                    AVVideoCodecKey: AVVideoCodecType.jpeg, 
                    AVVideoCompressionPropertiesKey: [
                        AVVideoQualityKey: "0.1"
                    ]
                ])

            let isFlashAvailable = self.deviceInput?.device.isFlashAvailable ?? false
            photoSettings.flashMode = isFlashAvailable ? .auto : .off
            photoSettings.photoQualityPrioritization = .speed

            if let photoOutputVideoConnection = photoOutput.connection(with: .video) {
                if  photoOutputVideoConnection.isVideoOrientationSupported,
                    let videoOrientation = self.videoOrientationFor(self.deviceOrientation)
                {
                    photoOutputVideoConnection.videoOrientation = videoOrientation
                }
            }

            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }

        return try await withCheckedThrowingContinuation { continuation in continuations.append(continuation) }
    }

    private func configureCaptureSession(completionHandler: (_ success: Bool) -> Void) {
        var success = false

        self.captureSession.beginConfiguration()

        defer {
            self.captureSession.commitConfiguration()
            completionHandler(success)
        }

        guard
            let captureDevice = captureDevice,
            let deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        else {
            logger.error(msg: "Failed to obtain video input.")
            return
        }

        let photoOutput = AVCapturePhotoOutput()

        captureSession.sessionPreset = AVCaptureSession.Preset.photo

        guard captureSession.canAddInput(deviceInput) else {
            logger.error(msg: "Unable to add device input to capture session.")
            return
        }
        guard captureSession.canAddOutput(photoOutput) else {
            logger.error(msg: "Unable to add photo output to capture session.")
            return
        }

        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)

        self.deviceInput = deviceInput
        self.photoOutput = photoOutput

        photoOutput.maxPhotoQualityPrioritization = .speed

        isCaptureSessionConfigured = true

        success = true
    }

    private func checkAuthorization() -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            logger.info(msg: "Camera access authorized.")
            return true
        case .notDetermined:
            logger.info(msg: "Camera access not determined.")
            return false
        case .denied:
            logger.info(msg: "Camera access denied.")
            return false
        case .restricted:
            logger.info(msg: "Camera library access restricted")
            return false
        @unknown default:
            return false
        }
    }

    private func deviceInputFor(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let device = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: device)
        } catch let error {
            logger.error(msg: "Error getting capture device input: \(error.localizedDescription)")
            return nil
        }
    }

    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
        guard isCaptureSessionConfigured else { return }

        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(deviceInput)
            }
        }

        if  let deviceInput = deviceInputFor(device: captureDevice),
            !captureSession.inputs.contains(deviceInput),
            captureSession.canAddInput(deviceInput)
        {
            captureSession.addInput(deviceInput)
        }
    }

    private func videoOrientationFor(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation? {
        switch deviceOrientation {
        case .portrait: return AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown: return AVCaptureVideoOrientation.portraitUpsideDown
        case .landscapeLeft: return AVCaptureVideoOrientation.landscapeLeft
        case .landscapeRight: return AVCaptureVideoOrientation.landscapeRight
        default: return nil
        }
    }

}

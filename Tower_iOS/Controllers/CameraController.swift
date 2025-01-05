//
//  CameraController.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2023-04-20.
//  Copyright (c) 2023-2025 valo.media GmbH. All rights reserved.
//

import Foundation
import AVFoundation
import CoreImage
import UIKit

// MARK: CameraController

/// The Controller for accessing the camera directly.
///
/// This contains the application logic for capturing photos and video from the device cameras.
///
class CameraController: NSObject, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: - Life cycle methods

    override init() {
        super.init()
        photoOutput.maxPhotoQualityPrioritization = .speed
        videoOutput.setSampleBufferDelegate(self, queue: captureQueue)
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]
        captureDevice = captureDevices.first
    }
    
    deinit {
        if torchEnabled {
            torchEnabled = false
        }
        if isRunning {
            captureSession.stopRunning()
        }
    }

    // MARK: - Properties

    /// The delegate to send the captured video frames to.
    ///
    weak var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?

    /// The subset of resolutions supported by all capture devices.
    ///
    lazy var universallySupportedResolutions: Set<CMVideoDimensions> = {
        let supportedResolutions = captureDevices.map { Set($0.formats.map(\.formatDescription.dimensions)) }
        return supportedResolutions.dropFirst().reduce(supportedResolutions.first) { $0?.intersection($1) } ?? []
    }()

    /// The currently used resolution.
    ///
    var captureDimensions: CMVideoDimensions? {
        get {
            (captureDevice != nil && isRunning) .!! _captureDimensions
        }
        set {
            guard let newValue, captureDevice != nil, isRunning else { return }
            captureQueue.async { [weak self] in self?._captureDimensions = self?.updateDeviceCaptureFormat(newValue) }
        }
    }
    private var _captureDimensions: CMVideoDimensions?

    /// The currently used frame rate.
    ///
    var captureFrameRate: Float64? {
        get {
            (captureDevice != nil && isRunning) .!! _captureFrameRate
        }
        set {
            guard let newValue, captureDevice != nil, isRunning else { return }
            captureQueue.async { [weak self] in self?._captureFrameRate = self?.updateVideoFrameRate(newValue) }
        }
    }
    private var _captureFrameRate: Float64?

    /// Whether the capture session is currently running.
    ///
    var isRunning: Bool {
        captureSession.isRunning
    }

    /// Whether the camera that is currently in use is one facing the user.
    ///
    var isUsingFrontCamera: Bool {
        guard let captureDevice else { return false }
        return captureDevice.position == .front
    }

    /// Whether the camer that is currently in use is one facing the world.
    ///
    var isUsingBackCamera: Bool {
        guard let captureDevice else { return false }
        return captureDevice.position == .back
    }

    /// Whether the flashlight is currenlty on.
    ///
    var torchEnabled: Bool = false {
        didSet {
            if let captureDevice, torchAvailable {
                captureQueue.async { [weak self] in
                    guard let self else { return }
                    do {
                        try captureDevice.lockForConfiguration()
                        if torchEnabled {
                            captureDevice.torchMode = .on
                        } else {
                            captureDevice.torchMode = .off
                        }
                        captureDevice.unlockForConfiguration()
                    } catch {
                        print("Unable to set torch on current camera. Error: \(error)")
                    }
                }
            } else {
                torchEnabled = false
                print("Torch is not available on current camera.")
            }
        }
    }

    /// Whether a flashlight is available on the camera that is in use.
    ///
    var torchAvailable: Bool {
        guard let captureDevice else { return false }
        return captureDevice.hasTorch && captureDevice.isTorchAvailable
    }

    private let cameraLock = NSLock()
    private let captureQueue = DispatchQueue(label: "captureQueue")
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let deviceType = AVCaptureDevice.DeviceType.builtInWideAngleCamera

    private var isCaptureSessionConfigured = false
    private var deviceInput: AVCaptureDeviceInput?
    private var orientation = UIInterfaceOrientation.portrait
    private var photoOutputContinuations: [CheckedContinuation<PhotoData, Error>] = []

    private var frontCaptureDevice: AVCaptureDevice? {
        AVCaptureDevice.default(deviceType, for: .video, position: .front)
    }
    
    private var backCaptureDevice: AVCaptureDevice? {
        AVCaptureDevice.default(deviceType, for: .video, position: .back)
    }

    private var captureDevices: [AVCaptureDevice] {
        [
            backCaptureDevice,
            frontCaptureDevice
        ]
            .compacted()
    }

    private var availableCaptureDevices: [AVCaptureDevice] {
        captureDevices.filter { $0.isConnected && !$0.isSuspended }
    }

    private var captureDevice: AVCaptureDevice? {
        didSet {
            guard let captureDevice else { return }
            print("Using capture device: \(captureDevice.localizedName)")
            captureQueue.async { [weak self] in self?.updateSessionForCaptureDevice(captureDevice) }
        }
    }

    private var deviceOrientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }

    // MARK: - Methods

    /// Start the capture session.
    ///
    /// This turns on the camera, once this is called, video will be output to the delegate. Before this is called,
    /// most methods (like taking a photo or setting the format) will have no effect.
    ///
    /// - Parameters:
    ///   - onCaptureFailed: A callback to invoke when the capture session cannot be started for whatever reason.
    ///
    func start(onCaptureFailed: @escaping (Error) -> Void) {
        guard captureDevice != nil else {
            print("No capture device available.")
            onCaptureFailed(CameraError.unavailable)
            return
        }
        
        let authorized = checkAuthorization()
        guard authorized else {
            print("Camera access was not authorized.")
            onCaptureFailed(CameraError.unauthorized)
            return
        }

        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                captureQueue.async { [self] in self.captureSession.startRunning() }
            }
            return
        }

        captureQueue.async { [self] in
            self.configureCaptureSession { success in
                guard success else {
                    onCaptureFailed(CameraError.configurationFailure)
                    return
                }
                self.captureSession.startRunning()
            }
        }
    }

    /// Stop the capture session.
    ///
    /// This can be called to end the capture session, once the cameras are no longer needed. Afterwards, capture can
    /// be restarted using the `start()` method.
    ///
    func stop() {
        guard isCaptureSessionConfigured, isRunning else { return }

        captureQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }

    /// Switch to the next available camera.
    ///
    /// Currently this will simply toggle back and forth between the front and back camera (assuming the device has
    /// both a front and a back camera, and both are available, which is currently true for all supported devices).
    ///
    func switchCamera() {
        if let captureDevice, let index = availableCaptureDevices.firstIndex(of: captureDevice) {
            let nextIndex = (index + 1) % availableCaptureDevices.count
            self.captureDevice = availableCaptureDevices[nextIndex]
        } else {
            self.captureDevice = AVCaptureDevice.default(for: .video)
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            print("Error capturing photo: \(error.localizedDescription)")
        }
        let data = photo.fileDataRepresentation()
        let size = ImageSize(photo.resolvedSettings.photoDimensions)

        for continuation in photoOutputContinuations {
            if let error {
                continuation.resume(throwing: error)
            } else if data == nil {
                continuation.resume(throwing: CameraError.exportFailed)
            } else {
                continuation.resume(returning: PhotoData(imageData: data!, imageSize: size))
            }
        }
        photoOutputContinuations = []
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let captureDevice, captureDevice.activeFormat.formatDescription.dimensions == _captureDimensions else {
            delegate?.captureOutput?(output, didDrop: sampleBuffer, from: connection)
            return
        }
        delegate?.captureOutput?(output, didOutput: sampleBuffer, from: connection)
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didDrop sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        delegate?.captureOutput?(output, didDrop: sampleBuffer, from: connection)
    }

    /// Take a photo.
    ///
    /// - Throws: 
    /// - Returns: The PhotoData for the photo that was taken.
    ///
    func takePhoto() async throws -> PhotoData {
        guard photoOutput.availablePhotoCodecTypes.contains(.jpeg) else {
            throw CameraError.codecUnavailable
        }

        // Temporarily switch to the highest resolution
        let captureDimensions = self.captureDimensions
        self.captureDimensions = CallQualityLevel.veryHigh.resolution.dimensions

        captureQueue.async { [weak self] in
            guard let self else { return }

            let photoSettings = AVCapturePhotoSettings(
                format: [
                    AVVideoCodecKey: AVVideoCodecType.jpeg, 
                    AVVideoCompressionPropertiesKey: [
                        AVVideoQualityKey: "0.5"
                    ]
                ])
            photoSettings.photoQualityPrioritization = .speed

            if let photoOutputVideoConnection = photoOutput.connection(with: .video) {
                if  photoOutputVideoConnection.isVideoOrientationSupported,
                    let videoOrientation = self.videoOrientationFor(self.deviceOrientation)
                {
                    photoOutputVideoConnection.videoOrientation = videoOrientation
                }
            }

            photoOutput.capturePhoto(with: photoSettings, delegate: self)

            // Turn the torch back on if necessary and switch back to the previous video format.
            self.captureDimensions = captureDimensions
            self.torchEnabled = torchEnabled
        }

        return try await withCheckedThrowingContinuation { continuation in photoOutputContinuations.append(continuation) }
    }

    private func configureCaptureSession(completionHandler: (_ success: Bool) -> Void) {
        var success = false

        cameraLock.lock()
        captureSession.beginConfiguration()
        
        defer {
            captureSession.commitConfiguration()
            cameraLock.unlock()
            completionHandler(success)
        }

        guard
            let captureDevice = captureDevice,
            let deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        else {
            print("Failed to obtain video input.")
            return
        }

        guard captureSession.canAddInput(deviceInput) else {
            print("Unable to add device input to capture session.")
            return
        }
        guard captureSession.canAddOutput(photoOutput) else {
            print("Unable to add photo output to capture session.")
            return
        }
        guard captureSession.canAddOutput(videoOutput) else {
            print("Unable to add video output to capture session.")
            return
        }

        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)

        self.deviceInput = deviceInput

        self._captureDimensions = updateDeviceCaptureFormat(CallQualityLevel.veryHigh.resolution.dimensions)
        self._captureFrameRate = updateVideoFrameRate(CallQualityLevel.veryHigh.frameRate)

        isCaptureSessionConfigured = true

        success = true
    }

    private func checkAuthorization() -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            print("Camera access not determined.")
            return false
        case .denied:
            print("Camera access denied.")
            return false
        case .restricted:
            print("Camera library access restricted")
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
            print("Error getting capture device input: \(error.localizedDescription)")
            return nil
        }
    }

    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
        guard isCaptureSessionConfigured else { return }
        cameraLock.lock()
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
            cameraLock.unlock()
        }

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

        _captureDimensions = _captureDimensions.flatMap(updateDeviceCaptureFormat)
        updateVideoOutputConnection()
    }
    
    private func updateVideoOutputConnection() {
        guard let videoOutputConnection = videoOutput.connection(with: .video) else { return }
        if videoOutputConnection.isVideoMirroringSupported {
            videoOutputConnection.isVideoMirrored = isUsingFrontCamera
        }
    }

    private func videoOrientationFor(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation? {
        switch deviceOrientation {
        case .portrait: return AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown: return AVCaptureVideoOrientation.portraitUpsideDown
        case .landscapeLeft: return AVCaptureVideoOrientation.landscapeRight
        case .landscapeRight: return AVCaptureVideoOrientation.landscapeLeft
        default: return nil
        }
    }

    @discardableResult
    private func updateDeviceCaptureFormat(_ dimensions: CMVideoDimensions) -> CMVideoDimensions? {
        guard let captureDevice else { return nil }
        try? captureDevice.lockForConfiguration()
        defer { captureDevice.unlockForConfiguration() }

        let newAVFormat = captureDevice
            .formats
            .filter { format in 
                format.formatDescription.mediaSubType == .init(rawValue: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            }
            .min { formatA, formatB in
                closestDimensions(
                    to: dimensions,
                    dimensionsA: formatA.formatDescription.dimensions,
                    dimensionsB: formatB.formatDescription.dimensions)
            }

        if let chosenFormat = newAVFormat, chosenFormat != captureDevice.activeFormat {
            print("Set resolution for capture device to \(chosenFormat.formatDescription.dimensions).")
            captureDevice.activeFormat = chosenFormat
            _captureFrameRate = _captureFrameRate.flatMap(updateVideoFrameRate)
        }

        return captureDevice.activeFormat.formatDescription.dimensions
    }

    private func closestDimensions(
        to dimensions: CMVideoDimensions,
        dimensionsA: CMVideoDimensions,
        dimensionsB: CMVideoDimensions
    ) -> Bool {
        let resolutionA = dimensionsA.width * dimensionsA.height
        let resolutionB = dimensionsB.width * dimensionsB.height

        if  dimensionsA.width >= dimensions.width,
            dimensionsA.height >= dimensions.height,
            dimensionsB.width >= dimensions.width,
            dimensionsB.height >= dimensions.height
        { return resolutionA < resolutionB }

        if  dimensionsA.width >= dimensions.width,
            dimensionsA.height >= dimensions.height
        { return true }

        if  dimensionsB.width >= dimensions.width,
            dimensionsB.height >= dimensions.height
        { return false }

        let usableResolutionA = calculateUsableResolution(cropping: dimensionsA, to: dimensions)
        let usableResolutionB = calculateUsableResolution(cropping: dimensionsB, to: dimensions)
        if usableResolutionA != usableResolutionB {
            return usableResolutionA > usableResolutionB
        }

        return resolutionA < resolutionB
    }

    private func calculateUsableResolution(cropping cameraDimensions: CMVideoDimensions, to streamDimensions: CMVideoDimensions) -> Int32 {
        return min(cameraDimensions.width, Int32(Double(cameraDimensions.height) * streamDimensions.aspectRatio))
            * min(cameraDimensions.height, Int32(Double(cameraDimensions.width) / streamDimensions.aspectRatio))
    }

    @discardableResult
    private func updateVideoFrameRate(_ frameRate: Float64) -> Float64? {
        guard let captureDevice else { return nil }
        try? captureDevice.lockForConfiguration()
        defer { captureDevice.unlockForConfiguration() }

        let timescale = closestFramerate(to: frameRate, in: captureDevice.activeFormat.videoSupportedFrameRateRanges)
        let duration = CMTime(value: 1, timescale: Int32(timescale))

        if captureDevice.activeVideoMinFrameDuration != duration || captureDevice.activeVideoMaxFrameDuration != duration {
            print("Set framerate for capture device to \(timescale) fps.")
            captureDevice.activeVideoMinFrameDuration = duration
            captureDevice.activeVideoMaxFrameDuration = duration
        }

        return timescale
    }

    private func closestFramerate(to frameRate: Float64, in supportedFrameRateRanges: [AVFrameRateRange]) -> Float64 {
        !supportedFrameRateRanges.filter { $0.maxFrameRate >= frameRate && frameRate >= $0.minFrameRate }.isEmpty
            .!! frameRate
            ?? supportedFrameRateRanges.map(\.minFrameRate).filter { $0 > frameRate }.sorted().first
            ?? captureDevice?.activeFormat.videoSupportedFrameRateRanges.map(\.maxFrameRate).sorted().last
            ?? frameRate
    }

}

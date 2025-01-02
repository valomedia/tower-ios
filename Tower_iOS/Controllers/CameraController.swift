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
/// This contains the application logic for capturing photos and video from the device cameras.
///
class CameraController:
    NSObject, CameraCaptureSource, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate
{

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
    
    var device: MediaDevice? {
        get {
            guard let captureDevice else { return nil }
            if (isUsingFrontCamera) {
                return MediaDevice(label: captureDevice.localizedName, type: MediaDeviceType.videoFrontCamera)
            }
            if (isUsingBackCamera) {
                return MediaDevice(label: captureDevice.localizedName, type: MediaDeviceType.videoBackCamera)
            }
            return MediaDevice(label: captureDevice.localizedName, type: MediaDeviceType.other)
        }
        set {
            guard let newValue else { return }
            captureDevice = AVCaptureDevice.default(
                deviceType,
                for: .video,
                position: newValue.type == .videoFrontCamera ? .front : .back)
        }
    }
    
    var videoContentHint: VideoContentHint = .motion

    var isRunning: Bool {
        captureSession.isRunning
    }
    
    var isUsingFrontCamera: Bool {
        guard let captureDevice else { return false }
        return captureDevice.position == .front
    }
    
    var isUsingBackCamera: Bool {
        guard let captureDevice else { return false }
        return captureDevice.position == .back
    }
    
    var format: VideoCaptureFormat = Settings.callQualityLevel.videoFormat {
        didSet {
            if captureDevice != nil, isRunning {
                captureQueue.async { [weak self] in self?.updateDeviceCaptureFormat() }
            }
        }
    }
    
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
                        logger.error(msg: "Unable to set torch on current camera. Error: \(error)")
                    }
                }
            } else {
                torchEnabled = false
                logger.info(msg: "Torch is not available on current camera.")
            }
        }
    }
    
    var torchAvailable: Bool {
        guard let captureDevice else { return false }
        return captureDevice.hasTorch && captureDevice.isTorchAvailable
    }
    
    private let logger = ConsoleLogger(name: "CameraController")
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
    private var sinks = ConcurrentMutableSet()
    private var captureSourceObservers = ConcurrentMutableSet()
    private var eventAnalyticsController: EventAnalyticsController?

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
            logger.info(msg: "Using capture device: \(captureDevice.localizedName)")
            captureQueue.async { [weak self] in self?.updateSessionForCaptureDevice(captureDevice) }
        }
    }

    private var deviceOrientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }

    // MARK: - Methods
    
    func addVideoSink(sink: VideoSink) {
        sinks.add(sink)
    }
    
    func removeVideoSink(sink: VideoSink) {
        sinks.remove(sink)
    }
       
    func addCaptureSourceObserver(observer: CaptureSourceObserver) {
        captureSourceObservers.add(observer)
    }
    
    func removeCaptureSourceObserver(observer: CaptureSourceObserver) {
        captureSourceObservers.remove(observer)
    }

    func setEventAnalyticsController(eventAnalyticsController: EventAnalyticsController?) {
        self.eventAnalyticsController = eventAnalyticsController
    }
 
    func start() {
        guard captureDevice != nil else {
            logger.error(msg: "No capture device available.")
            return
        }
        
        let authorized = checkAuthorization()
        guard authorized else {
            logger.error(msg: "Camera access was not authorized.")
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
                guard success else { return }
                self.captureSession.startRunning()
            }
        }
        
        captureSourceObservers.forEach { observer in (observer as? CaptureSourceObserver)?.captureDidStart() }
    }

    func stop() {
        guard isCaptureSessionConfigured, isRunning else { return }

        captureQueue.async { [weak self] in
            self?.captureSession.stopRunning()
            self?.captureSourceObservers.forEach { observer in (observer as? CaptureSourceObserver)?.captureDidStop() }
        }
    }

    func switchCamera() {
        if let captureDevice, let index = availableCaptureDevices.firstIndex(of: captureDevice) {
            let nextIndex = (index + 1) % availableCaptureDevices.count
            self.captureDevice = availableCaptureDevices[nextIndex]
        } else {
            self.captureDevice = AVCaptureDevice.default(for: .video)
        }        
        if captureDevice != nil {
            eventAnalyticsController?.pushHistory(historyEventName: .videoInputSelected)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            logger.error(msg: "Error capturing photo: \(error.localizedDescription)")
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
    
    func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
        guard let frame = VideoFrame(sampleBuffer: sampleBuffer) else {
            handleCaptureFailed(reason: .invalidFrame)
            logger.error(msg: "DefaultCameraCaptureSource could not convert captured CMSampleBuffer to video frame.")
            return
        }
        
        sinks.forEach { item in
            guard let sink = item as? VideoSink else { return }
            sink.onVideoFrameReceived(frame: frame)
        }
    }

    func takePhoto() async throws -> PhotoData {
        guard photoOutput.availablePhotoCodecTypes.contains(.jpeg) else {
            throw CameraError.codecUnavailable
        }

        // Temporarily switch to the highest resolution
        let format = self.format
        self.format = CallQualityLevel.high.videoFormat

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
            self.format = format
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
            handleCaptureFailed(reason: .configurationFailure)
            logger.error(msg: "Failed to obtain video input.")
            return
        }

        guard captureSession.canAddInput(deviceInput) else {
            handleCaptureFailed(reason: .configurationFailure)
            logger.error(msg: "Unable to add device input to capture session.")
            return
        }
        guard captureSession.canAddOutput(photoOutput) else {
            handleCaptureFailed(reason: .configurationFailure)
            logger.error(msg: "Unable to add photo output to capture session.")
            return
        }
        guard captureSession.canAddOutput(videoOutput) else {
            handleCaptureFailed(reason: .configurationFailure)
            logger.error(msg: "Unable to add video output to capture session.")
            return
        }

        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)

        self.deviceInput = deviceInput
        
        updateDeviceCaptureFormat()
        updateOrientation()

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
        
        updateVideoOutputConnection()
        updateOrientation()
    }
    
    private func updateVideoOutputConnection() {
        guard let videoOutputConnection = videoOutput.connection(with: .video) else { return }
        if videoOutputConnection.isVideoMirroringSupported {
            videoOutputConnection.isVideoMirrored = isUsingFrontCamera
        }
    }
    
    private func updateDeviceCaptureFormat() {
        guard let captureDevice else { return }
        try? captureDevice.lockForConfiguration()
        defer { captureDevice.unlockForConfiguration() }
        
        let newAVFormat = captureDevice.formats.min { avFormatA, avFormatB in
            let formatA = VideoCaptureFormat.fromAVCaptureDeviceFormat(format: avFormatA)
            let formatB = VideoCaptureFormat.fromAVCaptureDeviceFormat(format: avFormatB)
            return closestFormat(formatA: formatA, formatB: formatB)
        }
        guard let chosenFormat = newAVFormat, chosenFormat != captureDevice.activeFormat else { return }
        
        captureDevice.activeFormat = chosenFormat
    }
    
    private func closestFormat(formatA: VideoCaptureFormat, formatB: VideoCaptureFormat) -> Bool {
        let diffA = abs(formatA.width - format.width) + abs(formatA.height - format.height)
        let diffB = abs(formatB.width - format.width) + abs(formatB.height - format.height)
        if diffA == diffB {
            return abs(formatA.maxFrameRate - format.maxFrameRate) < abs(formatB.maxFrameRate - format.maxFrameRate)
        }
        return diffA < diffB
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
    
    private func updateOrientation() {
        guard
            let connection = videoOutput.connection(with: AVMediaType.video),
            let videoOrientation = videoOrientationFor(deviceOrientation)
        else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            connection.videoOrientation = videoOrientation
            
            // Need to reenable the torch if it was on before the rotation change caused the camera to restart.
            if self.torchEnabled {
                self.torchEnabled.toggle()
                self.torchEnabled.toggle()
            }
        }
    }
    
    @objc private func deviceOrientationDidChange(notification: NSNotification) {
        captureQueue.async { [weak self] in self?.updateOrientation() }
    }
    
    private func handleCaptureFailed(reason: CaptureSourceError) {
        let attributes = [EventAttributeName.videoInputError: reason]
        eventAnalyticsController?.publishEvent(name: .videoInputFailed, attributes: attributes)
        captureSourceObservers.forEach { observer in (observer as? CaptureSourceObserver)?.captureDidFail(error: reason) }
    }

}

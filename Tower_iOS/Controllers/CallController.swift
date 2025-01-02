//
//  CallController.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-04-20.
//
//

import Foundation
import CoreLocation
import AVFoundation
import SwiftUI
import AzureCommunicationCalling

// MARK: CallController

/// The controller for the call.
///
/// This contains for the application logic for the actual chime SDK itself.
///
class CallController: NSObject, ObservableObject, CallDelegate, CallAgentDelegate {

    // MARK: - Static properties

    /// The maximum allowable size for the data in the realtime data messages.
    ///
    static let dataMessageMaxSize = 32_000;

    /// The maximum number of realtime data messages to send in one burst.
    ///
    static let dataMessageMaxBurstCount = 99;
    
    static let durableDataChannelId: Int32 = 1000;
    
    static let lossyDataChannelId: Int32 = 1010;
    
    static let durableDataChannelBandwidthKbps: Int32 = 32;
    
    static let lossyDataChannelBandwidthKbps: Int32 = 512;
    
    static let lossyDataChannelChunkedMessageDelay = 1.0;
    
    static let dataChannelRetrySendDelay = 2.0;
    
    static let dataChannelEstablishDelay = 1.0;

    // MARK: - Properties

    /// The life-cycle state of the current session.
    ///
    @Published fileprivate(set) var sessionState: AssistanceSessionState = .none {
        didSet {
            UIAccessibility.post(notification: .announcement, argument: sessionState.localizedDescription)
        }
    }

    private var callClient: CallClient?
    private var callAgent: CallAgent?
    private var call: Call?
    private var deviceManager: DeviceManager?
    private var localVideoStream: LocalVideoStream?
    private var remoteParticipant: RemoteParticipant?
    private var locationController: LocationController? = nil

    private let cameraController = CameraController()
    private let audioSession = AVAudioSession.sharedInstance()

    // MARK: - Methods

    /// Callback to invoke when the call ends.
    ///
    /// This will be called whenever the call ends, no matter the reason.
    ///
    var onCallEnd: (() -> Void)? = nil
    
    /// Callback to invoke when the call ends because of a fata Error during the initial connection.
    ///
    /// This will be called when the call fails because of an Error received while establishing the call, that the
    /// call cannot automatically recover from. This is only called if the call fails, before it has even begun.
    /// Something like the caller losing the connection while talking to an assistant will not cause this callback to
    /// run, since this doesn't require specific handling outside of the call itself (such as showing an error message
    /// to the user).
    ///
    var onCallError: ((Error) -> Void)? = nil

    func startSession(onCallEnd: @escaping (() -> Void), onCallError: @escaping ((Error) -> Void)) {
        sessionState = .initializing
        self.onCallEnd = onCallEnd
        self.onCallError = onCallError

        AVPlayer.callRingbackTone.seek(to: CMTime.zero)
        AVPlayer.callRingbackTone.play()

        Task {
            do {
                try await createAgent(credential: try await createSession()).delegate = self
                DispatchQueue.main.async { self.sessionState = .waiting }
            } catch {
                handleSessionError(error)
            }
        }
    }

    func endSession() {
        AVPlayer.callRingbackTone.pause()
        AVPlayer.callEndTone.seek(to: CMTime.zero)
        AVPlayer.callEndTone.play()
        
        Task {
            do {
                try await hangUp()
            } catch {
                if sessionState == .waiting {
                    // Tell the backend we're gone. It's ok if this fails, the backend will notice on its own eventually.
                    Task { try? await TowerApi.cancelAssistance() }
                }

                disposeSession()
            }
        }
    }

    func call(_ call: Call, didChangeState args: PropertyChangedEventArgs) {
        if call.state == .connected { handleCallConnected() }
        if call.state == .disconnected { disposeSession() }
    }
    
    func callAgent(_ callAgent: CallAgent, didRecieveIncomingCall incomingCall: IncomingCall) {
        Task { await handleIncomingCall(incomingCall) }
    }

    func sendDataMessage(_ topic: DataMessageTopic, data: Data? = nil) {
    }

    private func createSession() async throws -> CommunicationTokenCredential {
        let requestAssistanceResponse = try await TowerApi.requestAssistance()
        _ = requestAssistanceResponse.keepaliveInterval.map { keepaliveInterval in
            Task { await sendKeepalives(keepaliveInterval) }
        }
        return try CommunicationTokenCredential(token: requestAssistanceResponse.userToken.token)
    }

    private func sendKeepalives(_ keepaliveInterval: Int) async {
        do { try await Task.sleep(for: .seconds(keepaliveInterval)) } catch { return }
        repeat {
            do { try await Task.sleep(for: .seconds(keepaliveInterval)) } catch { return }
            do {
                try await TowerApi.awaitAssistance()
            } catch {
                // Got an error updating the request. This might be because the assistant has already the request
                // and is in the process of picking up though, so give it a little time.
                do { try await Task.sleep(for: .seconds(keepaliveInterval)) } catch { return }
                if sessionState == .waiting {
                    // If we still haven't heard from the assistant by now, we probably have a connection issue.
                    handleSessionError(error)
                }
            }
        } while sessionState == .waiting
    }

    private func createAgent(credential: CommunicationTokenCredential) async throws -> CallAgent {
        let callClient = CallClient()
        let callAgent = try await callClient.createCallAgent(userCredential: credential)
        let deviceManager = try await callClient.getDeviceManager()

        self.callClient = callClient
        self.callAgent = callAgent
        self.deviceManager = deviceManager

        return callAgent
    }

    private func handleIncomingCall(_ incomingCall: IncomingCall) async {
        DispatchQueue.main.async { self.sessionState = .connecting }

        let camera = deviceManager?.cameras.first
        self.localVideoStream = camera.map { camera in LocalVideoStream(camera: camera) }

        let outgoingVideoOptions = OutgoingVideoOptions()
        outgoingVideoOptions.streams = [localVideoStream].compacted()

        let options = AcceptCallOptions()
        options.outgoingVideoOptions = outgoingVideoOptions

        do {
            let call = try await incomingCall.accept(options: options)
            call.delegate = self
            self.call = call
        } catch {
            try? await incomingCall.reject()
            handleSessionError(error)
        }

        // If no external devices are attached, switch to the loudspeaker.
        if (
            audioSession
                .currentRoute
                .outputs
                .filter { $0.portType != .builtInReceiver && $0.portType != .builtInSpeaker }
                .isEmpty
        ) {
            try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        }
    }

    private func hangUp() async throws {
        let options = HangUpOptions()
        options.forEveryone = true
        try await (call.!?).hangUp(options: options)
    }

    private func handleCallConnected() {
        DispatchQueue.main.async { self.sessionState = .connected }
        AVPlayer.callRingbackTone.pause()
        AVPlayer.callStartTone.seek(to: CMTime.zero)
        AVPlayer.callStartTone.play()
    }

    private func handleSessionError(_ error: Error) {
        AVPlayer.callRingbackTone.pause()
        AVPlayer.callErrorTone.seek(to: CMTime.zero)
        AVPlayer.callErrorTone.play()

        disposeSession()
        DispatchQueue.main.async { self.onCallError?(error) }
    }

    private func disposeSession() {
        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)

        cameraController.stop()
        cameraController.torchEnabled = false

        DispatchQueue.main.async {
            self.callClient = nil
            self.callAgent = nil
            self.call = nil
            self.deviceManager = nil
            self.localVideoStream = nil
            self.remoteParticipant = nil
            self.locationController = nil
            self.isVideoPaused = false

            self.onCallEnd?()
            self.onCallEnd = nil
            self.sessionState = .disconnected
        }
    }
    
    private func handleSwitchCameraRequest() {
        cameraController.switchCamera()
        sendDataMessage(.switchCameraResponse)
    }
    
    private func handleToggleTorchRequest() {
        cameraController.torchEnabled.toggle();
        sendDataMessage(.toggleTorchResponse)
    }
    
    private func handleLocationRequest() {
        do {
            try locationController?.requestLocation()
            sendDataMessage(.locationResponse)
        } catch {
            sendDataMessage(.locationResponse, data: try! JSONEncoder.shared.encode(["message": "\(error)"]))
        }
    }

    private func handleCapturePhotoRequest() {
        Task {
            do {
                let photoData = try await cameraController.takePhoto()
                print("Captured photo with a filesize of \(photoData.imageData.count / 1024) kB")
                
                let uuid = UUID()
                let encodedData = photoData.imageData.base64EncodedString()
                let chunkSize = try CallController.dataMessageMaxSize
                    - JSONEncoder
                        .shared
                        .encode(
                            CapturePhotoResponseData(
                                photoData: PhotoDataChunk(
                                    imageData: "",
                                    imageSize: photoData.imageSize,
                                    chunkingInfo: ChunkingInfo(
                                        index: CallController.dataMessageMaxBurstCount,
                                        count: CallController.dataMessageMaxBurstCount,
                                        uuid: uuid))))
                        .count
                let chunks = stride(from: 0, to: encodedData.count, by: chunkSize).map {
                    let start = encodedData.index(encodedData.startIndex, offsetBy: $0)
                    let end = encodedData.index(start, offsetBy: chunkSize, limitedBy: encodedData.endIndex)
                        ?? encodedData.endIndex
                    return String(encodedData[start..<end])
                }
                for (index, imageData) in chunks.enumerated() {
                    sendDataMessage(
                        .capturePhotoResponse,
                        data: try! JSONEncoder.shared.encode(
                                CapturePhotoResponseData(
                                photoData: PhotoDataChunk(
                                    imageData: imageData,
                                    imageSize: photoData.imageSize,
                                    chunkingInfo: ChunkingInfo(
                                        index: index,
                                        count: chunks.count,
                                        uuid: uuid)))))
                }
            } catch {
                sendDataMessage(
                    .capturePhotoResponse,
                    data: try! JSONEncoder.shared.encode(CapturePhotoResponseData(message: "\(error)")))
            }
        }
    }

}

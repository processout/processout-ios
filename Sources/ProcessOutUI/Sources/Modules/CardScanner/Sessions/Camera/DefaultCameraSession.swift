//
//  DefaultCameraSession.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.12.2024.
//

// swiftlint:disable type_body_length

import AVFoundation
import CoreImage
@_spi(PO) import ProcessOut

/// An actor that manages the capture pipeline, which includes the capture session, device inputs, and capture outputs.
/// The app defines it as an `actor` type to ensure that all camera operations happen off of the `@MainActor`.
actor DefaultCameraSession:
    NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, CameraSession, CameraSessionPreviewSource {

    init(logger: POLogger) {
        dispatchQueue = DispatchQueue(label: "processout.camera-session", qos: .userInitiated)
        executor = DispatchQueueExecutor(queue: dispatchQueue)
        isConfigured = false
        observations = []
        self.logger = logger
        super.init()
    }

    // MARK: - Actor

    nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }

    // MARK: - CameraSession

    @discardableResult
    func start() async -> Bool {
        guard await isAuthorized else {
            return false
        }
        guard !captureSession.isRunning else {
            return true
        }
        guard configureSession() else {
            return false
        }
        captureSession.startRunning()
        return captureSession.isRunning
    }

    func stop() {
        captureSession.stopRunning()
    }

    func setDelegate(_ delegate: CameraSessionDelegate?) {
        self.delegate = delegate
    }

    // MARK: - Preview

    func addPreviewLayer(_ layer: AVCaptureVideoPreviewLayer) {
        guard layer.session != captureSession else {
            logger.debug("Ignoring attempt to add preview layer that is already associated with same session..")
            return
        }
        layer.session = captureSession
    }

    func removePreviewLayer(_ layer: AVCaptureVideoPreviewLayer) {
        guard let session = layer.session else {
            logger.debug("Preview layer has no associated session, ignoring removal attempt.")
            return
        }
        if session !== captureSession {
            logger.error("Will remove preview layer that is not associated with this session.")
        }
        layer.session = nil
    }

    // MARK: - Torch

    var isTorchEnabled: Bool {
        guard let device = activeVideoInput?.device else {
            return false
        }
        return device.torchMode != .off
    }

    @discardableResult
    func setTorchEnabled(_ isEnabled: Bool) -> Bool {
        guard let device = activeVideoInput?.device else {
            return false
        }
        guard device.hasTorch else {
            return false
        }
        do {
            try device.lockForConfiguration()
            defer {
                device.unlockForConfiguration()
            }
            if isEnabled {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            } else {
                device.torchMode = .off
            }
        } catch {
            logger.debug("Did fail to change torch level: \(error).")
            return false
        }
        return true
    }

    // MARK: - CameraSessionPreviewSource

    nonisolated var previewSource: CameraSessionPreviewSource {
        self
    }

    nonisolated func connect(to target: any CameraSessionPreviewTarget) {
        Task { await target.setCameraSession(self) }
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard !shouldDiscardVideoFrames.wrappedValue, let imageBuffer = sampleBuffer.imageBuffer else {
            return
        }
        let image = CIImage(cvImageBuffer: imageBuffer)
        Task {
            let correctedImage = await self.corrected(
                image: image, videoOrientation: connection.videoOrientation
            )
            await delegate?.cameraSession(self, didOutput: correctedImage)
            shouldDiscardVideoFrames.withLock { $0 = false }
        }
        shouldDiscardVideoFrames.withLock { $0 = true }
    }

    // MARK: - Private Properties

    private let dispatchQueue: DispatchQueue
    private let executor: any SerialExecutor
    private let logger: POLogger
    private let captureSession = AVCaptureSession()

    private var isConfigured: Bool
    private var observations: [NSObjectProtocol]
    private var activeVideoInput: AVCaptureDeviceInput?
    private var activeVideoDataOutput: AVCaptureVideoDataOutput?
    private weak var delegate: CameraSessionDelegate?

    /// Boolean value indicating whether new video frames should be discarded.
    private nonisolated(unsafe) var shouldDiscardVideoFrames = POUnfairlyLocked(wrappedValue: false)

    // MARK: - Authorization

    /// A Boolean value that indicates whether a user authorizes this app to use device cameras.
    private var isAuthorized: Bool {
        get async {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                return true
            case .denied, .restricted:
                return false
            case .notDetermined:
                // If the system hasn't determined their authorization status,
                // explicitly prompt them for approval.
                return await AVCaptureDevice.requestAccess(for: .video)
            @unknown default:
                return false
            }
        }
    }

    // MARK: - Session Configuration

    private func configureSession() -> Bool {
        guard !isConfigured else {
            return true // Return early if already configured.
        }
        observeNotifications()
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        guard configureSessionInput(), configureSessionOutput() else {
            return false
        }
        isConfigured = true
        return true
    }

    private func configureSessionInput() -> Bool {
        guard activeVideoInput == nil else {
            return true // Already configured
        }
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInTripleCamera, .builtInDualWideCamera, .builtInUltraWideCamera, .builtInWideAngleCamera
            ],
            mediaType: .video,
            position: .back
        )
        guard let device = discoverySession.devices.first else {
            return false
        }
        let videoInput: AVCaptureDeviceInput
        do {
            try configure(captureDevice: device)
            videoInput = try AVCaptureDeviceInput(device: device)
        } catch {
            return false
        }
        guard captureSession.canAddInput(videoInput) else {
            return false
        }
        captureSession.addInput(videoInput)
        self.activeVideoInput = videoInput
        return true
    }

    private func configureSessionOutput() -> Bool {
        guard activeVideoDataOutput == nil else {
            return true // Already configured
        }
        let videoOutput = createVideoOutput()
        guard captureSession.canAddOutput(videoOutput) else {
            return false
        }
        captureSession.addOutput(videoOutput)
        self.activeVideoDataOutput = videoOutput
        return true
    }

    private func configure(captureDevice device: AVCaptureDevice) throws {
        try device.lockForConfiguration()
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
            device.whiteBalanceMode = .continuousAutoWhiteBalance
        }
        if device.isLowLightBoostSupported {
            device.automaticallyEnablesLowLightBoostWhenAvailable = true
        }
        if device.isAutoFocusRangeRestrictionSupported {
            device.autoFocusRangeRestriction = .near
        }
        device.unlockForConfiguration()
    }

    private func createVideoOutput() -> AVCaptureVideoDataOutput {
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
        ]
        output.setSampleBufferDelegate(self, queue: dispatchQueue)
        return output
    }

    // MARK: - Notifications

    private func observeNotifications() {
        let errorsObservation = NotificationCenter.default.addObserver(
            forName: .AVCaptureSessionRuntimeError,
            object: nil,
            queue: nil,
            using: { [weak self] notification in
                self?.didReceiveRuntimeErrorNotification(notification)
            }
        )
        observations = [errorsObservation]
    }

    private nonisolated func didReceiveRuntimeErrorNotification(_ notification: Notification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError,
              case .mediaServicesWereReset = error.code else {
            return
        }
        // If the system resets media services, the capture session stops running.
        Task { await start() }
    }

    // MARK: - Image Correction

    @MainActor
    private func corrected(image: CIImage, videoOrientation: AVCaptureVideoOrientation) async -> CIImage {
        let rotatedImage = image.transformed(
            by: .init(rotationAngle: await videoRotationAngle(for: videoOrientation))
        )
        let translatedImage = rotatedImage.transformed(
            by: .init(translationX: -rotatedImage.extent.origin.x, y: -rotatedImage.extent.origin.y)
        )
        if let previewSize = await videoPreviewLayer?.owningView?.bounds.size {
            let scaledRect = AVMakeRect(
                aspectRatio: previewSize, insideRect: translatedImage.extent
            )
            let previewTransform = CGAffineTransform
                .identity
                .scaledBy(x: previewSize.width / scaledRect.width, y: previewSize.height / scaledRect.height)
                .translatedBy(x: -scaledRect.minX, y: -scaledRect.minY)
            let croppedRect = await delegate?
                .cameraSession(self, regionOfInterestInside: scaledRect.applying(previewTransform))?
                .applying(previewTransform.inverted())
            return translatedImage.cropped(to: croppedRect ?? scaledRect)
        }
        return translatedImage
    }

    /// Returns rotation angle in radians.
    @MainActor
    private func videoRotationAngle(for videoOrientation: AVCaptureVideoOrientation) async -> CGFloat {
        var angle: CGFloat
        switch videoOrientation {
        case .landscapeLeft:
            angle = 90
        case .portraitUpsideDown:
            angle = 180
        case .landscapeRight:
            angle = 270
        default:
            angle = 0
        }
        switch await videoPreviewLayer?.owningView?.window?.windowScene?.interfaceOrientation {
        case .landscapeRight:
            angle += 90
        case .portraitUpsideDown:
            angle += 180
        case .landscapeLeft:
            angle += 270
        default:
            angle += 0
        }
        return (angle / 180).truncatingRemainder(dividingBy: 360) * .pi
    }

    // MARK: - Preview Layer

    private var videoPreviewLayer: AVCaptureVideoPreviewLayer? {
        for connection in captureSession.connections {
            if let layer = connection.videoPreviewLayer {
                return layer
            }
        }
        return nil
    }
}

// swiftlint:enable type_body_length

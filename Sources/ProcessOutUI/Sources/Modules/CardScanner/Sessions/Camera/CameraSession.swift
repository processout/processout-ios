//
//  CameraSession.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 12.11.2024.
//

import AVFoundation

/// An actor that manages the capture pipeline, which includes the capture session, device inputs, and capture outputs.
/// The app defines it as an `actor` type to ensure that all camera operations happen off of the `@MainActor`.
actor CameraSession {

    init() {
        isConfigured = false
        observations = []
    }

    /// Capture session.
    let captureSession = AVCaptureSession()

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

    // MARK: - Outputs Management

    func addOutput(_ output: AVCaptureOutput) -> Bool {
        guard captureSession.canAddOutput(output) else {
            return false
        }
        captureSession.beginConfiguration()
        captureSession.addOutput(output)
        captureSession.commitConfiguration()
        return true
    }

    func removeOutput(_ output: AVCaptureOutput) {
        captureSession.beginConfiguration()
        captureSession.removeOutput(output)
        captureSession.commitConfiguration()
    }

    // MARK: - Private Properties

    private var isConfigured: Bool
    private var observations: [NSObjectProtocol]

    /// The video input for the currently selected device camera.
    private var activeVideoInput: AVCaptureDeviceInput?

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
        guard configureSessionInput() else {
            return false
        }
        isConfigured = true
        return true
    }

    private func configureSessionInput() -> Bool {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
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
        captureSession.beginConfiguration()
        captureSession.addInput(videoInput)
        captureSession.commitConfiguration()
        self.activeVideoInput = videoInput
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
        device.unlockForConfiguration()
    }

    // MARK: - Notifications

    private func observeNotifications() {
        let errorsObservation = NotificationCenter.default.addObserver(
            forName: AVCaptureSession.runtimeErrorNotification,
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
}

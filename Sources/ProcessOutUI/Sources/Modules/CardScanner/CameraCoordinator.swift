//
//  CameraCoordinator.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 12.11.2024.
//

import AVFoundation

@MainActor
final class CameraCoordinator {

    nonisolated init() {
        // Ignored
    }

    /// Capture session.
    let session = AVCaptureSession()

    /// Capture device.
    private(set) var captureDevice: AVCaptureDevice?

    /// Coordinator delegate.
    weak var delegate: CameraCoordinatorDelegate?

    nonisolated func start() async -> Bool {
        await configureSession()
        await session.startRunning()
    }

    // MARK: - Session Configuration

    private func configureSession() {
        session.beginConfiguration()
        if !configureInput() {
            assertionFailure("Unable to configure input.")
        }
        session.commitConfiguration()
    }

    private func configureInput() -> Bool {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            assertionFailure("Capture device is unavailable.")
            return false
        }
        let deviceInput: AVCaptureDeviceInput
        do {
            deviceInput = try AVCaptureDeviceInput(device: device)
            try configureCaptureDevice(device)
        } catch {
            assertionFailure("Unable to create and configure capture device.")
            return false
        }
        guard session.canAddInput(deviceInput) else {
            assertionFailure("Unable to add capture device.")
            return false
        }
        session.addInput(deviceInput)
        return true
    }

    private func configureCaptureDevice(_ device: AVCaptureDevice) throws {
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
}

protocol CameraCoordinatorDelegate: AnyObject {

    /// Called when camera coordinator outputs image buffer.
    ///
    /// - Parameters:
    ///   - orientation: actual orientation of video buffer.
    ///
    /// - NOTE: Method is called on background thread.
    func cameraCoordinator(
        _ coordinator: CameraCoordinator, didOutput imageBuffer: CVImageBuffer, orientation: CGImagePropertyOrientation
    )

    /// Foo
    func cameraCoordinator(_ coordinator: CameraCoordinator, didFail failure: Error)
}

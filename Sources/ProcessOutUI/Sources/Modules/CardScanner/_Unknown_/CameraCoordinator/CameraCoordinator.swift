//
//  CameraCoordinator.swift
//  vision-test
//
//  Created by Andrii Vysotskyi on 26.01.2024.
//

import UIKit
import AVFoundation
@_spi(PO) import ProcessOut

final class CameraCoordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    override init() {
        session = AVCaptureSession()
        workQueue = DispatchQueue(label: "CameraCoordinator", qos: .userInitiated, autoreleaseFrequency: .workItem)
        super.init()
        commonInit()
    }

    /// Capture session.
    let session: AVCaptureSession

    func setDelegate(_ delegate: CameraCoordinatorDelegate? = nil) {
        workQueue.sync { self.delegate = delegate }
    }

    func start() {
        // todo(andrii-vysotskyi): observe AVCaptureSessionRuntimeErrorNotification
        workQueue.async(execute: session.startRunning)
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let imageBuffer = sampleBuffer.imageBuffer else {
            return
        }
        delegate?.cameraCoordinator(self, didOutput: imageBuffer, orientation: bufferOrientation)
    }

    // MARK: - Private Properties

    private lazy var videoOutput: AVCaptureVideoDataOutput = {
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
        ]
        output.setSampleBufferDelegate(self, queue: workQueue)
        return output
    }()

    private let workQueue: DispatchQueue

    /// Coordinator delegate.
    private weak var delegate: CameraCoordinatorDelegate?

    // MARK: - Private Methods

    private func commonInit() {
        configureSession()
    }

    // MARK: - Session Configuration

    private func configureSession() {
        session.beginConfiguration()
        if !configureInput() {
            assertionFailure("Unable to configure input.")
        }
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        if let connection = videoOutput.connection(with: .video) {
            connection.isEnabled = true
            connection.videoOrientation = .portrait
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

    // MARK: - Orientation Utils

    /// - NOTE: Method expects that connection's video orientation is set to portrait.
    private var bufferOrientation: CGImagePropertyOrientation {
        switch UIDevice.current.orientation {
        case .portrait:
            return .up
        case .landscapeLeft:
            return .right
        case .portraitUpsideDown:
            return .down
        case .landscapeRight:
            return .left
        default:
            return .up
        }
    }
}

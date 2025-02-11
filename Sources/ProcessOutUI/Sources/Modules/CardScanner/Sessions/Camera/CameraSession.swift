//
//  CameraSession.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 12.11.2024.
//

import AVFoundation
import CoreImage

/// A session that manages the capture pipeline, which includes the capture session, device inputs, and capture outputs.
protocol CameraSession: Sendable, AnyObject {

    /// Starts camera session.
    @discardableResult
    func start() async -> Bool

    /// Stops camera session.
    func stop() async

    /// Adds delegate to camera session.
    func setDelegate(_ delegate: CameraSessionDelegate?) async

    // MARK: - Preview

    /// Adds given preview layer to camera session.
    func addPreviewLayer(_ layer: AVCaptureVideoPreviewLayer) async

    /// Removes given preview layer from camera session.
    func removePreviewLayer(_ layer: AVCaptureVideoPreviewLayer) async

    // MARK: - Torch

    /// Boolean value indicating whether torch is currently enabled.
    var isTorchEnabled: Bool { get async }

    /// Changes torch mode.
    /// - Returns: Boolean value indicating whether the change was successful.
    @discardableResult
    func setTorchEnabled(_ isEnabled: Bool) async -> Bool

    // MARK: - Preview

    /// Returns preview source.
    nonisolated var previewSource: CameraSessionPreviewSource { get }

    /// Asks camera session to connect to given preview target.
    nonisolated func connect(to target: any CameraSessionPreviewTarget)
}

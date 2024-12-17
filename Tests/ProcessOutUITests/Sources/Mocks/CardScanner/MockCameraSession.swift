//
//  MockCameraSession.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.12.2024.
//

import AVFoundation
@testable import ProcessOutUI

actor MockCameraSession: CameraSession {

    init(isTorchEnabled: Bool = false) {
        self.isTorchEnabled = isTorchEnabled
    }

    // MARK: - CameraSession

    func start() async -> Bool {
        startCallsCount += 1
        return await startFromClosure()
    }

    func stop() {
        stopCallsCount += 1
    }

    func setDelegate(_ delegate: CameraSessionDelegate?) {
        setDelegateCallsCount += 1
        self.delegate = delegate
    }

    private(set) var isTorchEnabled: Bool

    func setTorchEnabled(_ isEnabled: Bool) -> Bool {
        isTorchEnabled = isEnabled
        return true
    }

    // MARK: -

    /// Number of times `setDelegate` has been called.
    private(set) var setDelegateCallsCount = 0

    /// Current delegate for the camera session.
    private(set) var delegate: CameraSessionDelegate?

    /// Number of times `start` has been called.
    private(set) var startCallsCount = 0

    /// Closure to provide the result of the `start` operation.
    var startFromClosure: (() async -> Bool)!

    /// Number of times `stop` has been called.
    private(set) var stopCallsCount = 0
}

// swiftlint:disable unavailable_function

extension MockCameraSession {

    func addConnection(_ connection: AVCaptureConnection) -> Bool {
        fatalError("Not implemented.")
    }

    nonisolated var previewSource: CameraSessionPreviewSource {
        fatalError("Not implemented.")
    }

    nonisolated func connect(to target: any CameraSessionPreviewTarget) {
        fatalError("Not implemented.")
    }
}

// swiftlint:enable unavailable_function

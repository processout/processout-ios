//
//  CameraSessionPreviewSource.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 06.12.2024.
//

import AVFoundation

/// A protocol that enables a preview source to connect to a preview target.
protocol CameraSessionPreviewSource: Sendable {

    /// Connects a preview destination to this source.
    func connect(to target: CameraSessionPreviewTarget)
}

/// A protocol that passes the app's capture session to the camera preview view.
protocol CameraSessionPreviewTarget: Sendable {

    /// Sets the capture session on the destination.
    @MainActor
    func setCameraSession(_ cameraSession: CameraSession)
}

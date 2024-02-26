//
//  CameraCoordinatorDelegate.swift
//  vision-test
//
//  Created by Andrii Vysotskyi on 26.01.2024.
//

import AVFoundation

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

    func cameraCoordinator(_ coordinator: CameraCoordinator, didFail failure: CameraCoordinatorFailure)
}

//
//  CameraSessionDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.11.2024.
//

import CoreImage

protocol CameraSessionDelegate: AnyObject, Sendable {

    /// Informs delegate about output image.
    func cameraSession(_ session: CameraSession, didOutput image: CIImage) async
}

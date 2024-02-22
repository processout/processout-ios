//
//  CameraPreviewOrientationPreferenceKey.swift
//  vision-test
//
//  Created by Andrii Vysotskyi on 20.02.2024.
//

import SwiftUI
import CoreGraphics

@_spi(PO) public struct POCameraPreviewOrientationPreferenceKey: PreferenceKey {

    public static var defaultValue: CGImagePropertyOrientation = .up

    public static func reduce(value: inout CGImagePropertyOrientation, nextValue: () -> CGImagePropertyOrientation) {
        value = nextValue()
    }
}

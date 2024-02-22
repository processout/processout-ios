//
//  CameraPreviewOrientationPreferenceKey.swift
//  vision-test
//
//  Created by Andrii Vysotskyi on 20.02.2024.
//

import SwiftUI
import CoreGraphics

@_spi(PO) public struct POCameraPreviewOrientationPreferenceKey: PreferenceKey {

    static var defaultValue: CGImagePropertyOrientation = .up

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

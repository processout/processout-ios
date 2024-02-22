//
//  CameraPreviewOrientationPreferenceKey.swift
//  vision-test
//
//  Created by Andrii Vysotskyi on 20.02.2024.
//

import SwiftUI
import CoreGraphics

struct CameraPreviewOrientationPreferenceKey: PreferenceKey {

    static var defaultValue: CGImagePropertyOrientation = .up

    static func reduce(value: inout CGImagePropertyOrientation, nextValue: () -> CGImagePropertyOrientation) {
        value = nextValue()
    }
}

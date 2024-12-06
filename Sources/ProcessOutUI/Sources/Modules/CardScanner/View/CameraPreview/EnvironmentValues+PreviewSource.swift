//
//  EnvironmentValues+PreviewSource.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.11.2024.
//

import AVFoundation
import SwiftUI

extension EnvironmentValues {

    var cameraSessionPreviewSource: CameraSessionPreviewSource? {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    private struct Key: EnvironmentKey {
        static let defaultValue: CameraSessionPreviewSource? = nil
    }
}

extension View {

    func cameraSessionPreviewSource(_ source: CameraSessionPreviewSource?) -> some View {
        environment(\.cameraSessionPreviewSource, source)
    }
}

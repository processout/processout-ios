//
//  EnvironmentValues+CaptureSession.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.11.2024.
//

import AVFoundation
import SwiftUI

extension EnvironmentValues {

    var cameraPreviewCaptureSession: AVCaptureSession? {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    private struct Key: EnvironmentKey {
        static let defaultValue: AVCaptureSession? = nil
    }
}

extension View {

    func cameraPreviewCaptureSession(_ captureSession: AVCaptureSession?) -> some View {
        environment(\.cameraPreviewCaptureSession, captureSession)
    }
}

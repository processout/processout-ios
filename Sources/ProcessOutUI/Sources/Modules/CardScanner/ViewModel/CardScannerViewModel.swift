//
//  CardScannerViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 22.02.2024.
//

import AVFoundation

protocol CardScannerViewModel: ObservableObject {

    /// Screen title.
    var title: String { get }

    /// Capture session.
    var captureSession: AVCaptureSession { get }
}

//
//  POCardScannerView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 12.11.2024.
//

import SwiftUI
import AVFoundation

@_spi(PO) import ProcessOutCoreUI

@_spi(PO)
@available(iOS 14, *)
public struct POCardScannerView: View {

    init(viewModel: @autoclosure @escaping () -> some ViewModel<CardScannerViewModelState>) {
        self._viewModel = .init(wrappedValue: .init(erasing: viewModel()))
    }

    // MARK: - View

    public var body: some View {
        VStack(spacing: POSpacing.medium) {
            Text(viewModel.state.title)
            CameraPreviewView()
                .cameraPreviewCaptureSession(viewModel.state.preview.captureSession)
                .aspectRatio(viewModel.state.preview.aspectRatio, contentMode: .fit)
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, POSpacing.medium)
        .padding(.horizontal, POSpacing.large)
        .onAppear(perform: viewModel.start)
    }

    // MARK: - Private Properties

    @StateObject
    private var viewModel: AnyViewModel<CardScannerViewModelState>
}

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
        let configuration = POCardScannerStyleConfiguration(
            title: {
                if let title = viewModel.state.title {
                    Text(title)
                }
            },
            description: {
                if let description = viewModel.state.description {
                    Text(description)
                }
            },
            videoPreview: {
                CameraPreviewView()
                    .cameraPreviewCaptureSession(viewModel.state.preview.captureSession)
                    .aspectRatio(viewModel.state.preview.aspectRatio, contentMode: .fit)
                    .frame(maxWidth: .infinity)
            },
            cancelButton: {
                if let viewModel = viewModel.state.cancelButton {
                    Button.create(with: viewModel)
                        .backport.poControlSize(.small)
                }
            }
        )
        AnyView(style.makeBody(configuration: configuration))
            .onAppear(perform: viewModel.start)
    }

    // MARK: - Private Properties

    @StateObject
    private var viewModel: AnyViewModel<CardScannerViewModelState>

    @Environment(\.cardScannerStyle)
    private var style
}

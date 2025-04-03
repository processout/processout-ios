//
//  POCardScannerView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 12.11.2024.
//

import SwiftUI
import AVFoundation
@_spi(PO) import ProcessOutCoreUI

/// `POCardScannerView` is a SwiftUI view that allows users to scan payment cards using
/// the camera. It provides a streamlined interface to automatically recognize card details: number,
/// expiration date, and cardholder name.
@available(iOS 14, *)
@MainActor
public struct POCardScannerView: View {

    init(viewModel: @autoclosure @escaping () -> some ViewModel<CardScannerViewModelState>) {
        self._viewModel = .init(wrappedValue: .init(erasing: viewModel()))
    }

    // MARK: - View

    public var body: some View {
        AnyView(
            style.makeBody(configuration: styleConfiguration)
        )
        .onAppear(perform: viewModel.start)
    }

    // MARK: - Private Properties

    @StateObject
    private var viewModel: AnyViewModel<CardScannerViewModelState>

    @Environment(\.cardScannerStyle)
    private var style

    // MARK: - Private Methods

    private var styleConfiguration: POCardScannerStyleConfiguration {
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
            torchToggle: {
                Toggle(isOn: viewModel.state.isTorchEnabled) {
                    Label {
                        EmptyView()
                    } icon: {
                        let isOn = viewModel.state.isTorchEnabled.wrappedValue
                        let icon = Image(poResource: isOn ? .lightningSlash : .lightning)
                        icon.renderingMode(.template).resizable()
                    }
                }
                .fixedSize()
            },
            videoPreview: {
                CameraPreviewView()
                    .cameraSessionPreviewSource(viewModel.state.preview.source)
            },
            cancelButton: {
                if let viewModel = viewModel.state.cancelButton {
                    Button.create(with: viewModel)
                }
            },
            card: cardStyleConfiguration
        )
        return configuration
    }

    private var cardStyleConfiguration: POCardScannerStyleConfiguration.Card? {
        guard let viewModel = self.viewModel.state.recognizedCard else {
            return nil
        }
        let cardConfiguration = POCardScannerStyleConfiguration.Card(
            number: {
                Text(viewModel.number)
            },
            expiration: {
                if let expiration = viewModel.expiration {
                    Text(expiration)
                }
            },
            cardholderName: {
                if let cardholderName = viewModel.cardholderName {
                    Text(cardholderName)
                }
            }
        )
        return cardConfiguration
    }
}

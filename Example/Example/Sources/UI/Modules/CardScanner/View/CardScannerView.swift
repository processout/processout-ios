//
//  CardScannerView.swift
//  Example
//
//  Created by Andrii Vysotskyi on 03.12.2024.
//

import SwiftUI
import ProcessOut
@_spi(PO) import ProcessOutUI

struct CardScannerView: View {

    var body: some View {
        Form {
            if let viewModel = message {
                MessageView(viewModel: viewModel)
            }
            Button(String(localized: .CardScanner.scan)) {
                message = nil
                isCardScannerPresented = true
            }
        }
        .sheet(isPresented: $isCardScannerPresented) {
            POCardScannerView { result in
                didScanCard(result: result)
            }
            .presentationDetents([.medium, .large])
        }
        .navigationTitle(String(localized: .CardScanner.title))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Private Properties

    @State
    private var isCardScannerPresented = false

    @State
    private var message: MessageViewModel?

    // MARK: - Private Methods

    private func didScanCard(result: Result<POScannedCard, POFailure>) {
        switch result {
        case .success(let scannedCard):
            let text = String(
                localized: .CardScanner.successMessage,
                replacements: scannedCard.number,
                scannedCard.cardholderName ?? "N/A",
                scannedCard.expiration?.description ?? "N/A"
            )
            message = .init(text: text, severity: .success)
        case .failure(let failure) where failure.code != .cancelled:
            message = .init(text: String(localized: .CardScanner.errorMessage), severity: .error)
        case .failure:
            break
        }
        isCardScannerPresented = false
    }
}

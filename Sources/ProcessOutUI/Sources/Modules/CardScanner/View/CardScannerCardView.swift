//
//  CardScannerCardView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.12.2024.
//

import SwiftUI

struct CardScannerCardView: View {

    let viewModel: CardScannerViewModelState.Card

    // MARK: - View

    var body: some View {
        VStack {
            Text(viewModel.number)
            HStack {
                if let cardholderName = viewModel.cardholderName {
                    Text(cardholderName)
                }
                if let expiration = viewModel.expiration {
                    Text(expiration)
                }
            }
        }
    }
}

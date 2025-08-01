//
//  SavedPaymentMethodView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.12.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@MainActor
struct SavedPaymentMethodView: View {

    let viewModel: SavedPaymentMethodsViewModelState.PaymentMethod

    // MARK: - View

    var body: some View {
        let configuration = POSavedPaymentMethodStyleConfiguration {
            POAsyncImage(resource: viewModel.logo) {
                Color.black.clipShape(RoundedRectangle(cornerRadius: POSpacing.extraSmall))
            }
        } name: {
            Text(viewModel.name)
        } description: {
            if let description = viewModel.description {
                Text(description)
            }
        } deleteButton: {
            if let viewModel = viewModel.deleteButton {
                Button.create(with: viewModel)
            }
        }
        AnyView(style.makeBody(configuration: configuration))
            .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.savedPaymentMethodStyle)
    private var style
}

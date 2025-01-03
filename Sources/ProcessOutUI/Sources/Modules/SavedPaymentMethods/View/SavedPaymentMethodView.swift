//
//  SavedPaymentMethodView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.12.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
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
            Button.create(with: viewModel.deleteButton)
        }
        AnyView(style.makeBody(configuration: configuration))
            .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.savedPaymentMethodStyle)
    private var style
}

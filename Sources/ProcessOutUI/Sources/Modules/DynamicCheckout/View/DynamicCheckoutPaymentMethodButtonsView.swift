//
//  DynamicCheckoutPaymentMethodButtonsView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
@MainActor
struct DynamicCheckoutPaymentMethodButtonsView: View {

    /// Available actions.
    let buttons: [POButtonViewModel]

    // MARK: - View

    var body: some View {
        let buttons = self.buttons.filter(isIncluded)
        VStack(spacing: POSpacing.small) {
            ForEach(buttons) { buttonViewModel in
                Button.create(with: buttonViewModel)
                    .buttonStyle(
                        forPrimaryRole: style.actionsContainer.primary,
                        fallback: style.actionsContainer.secondary
                    )
            }
        }
        .backport.geometryGroup()
        .modify(when: buttons.isEmpty) { _ in
            EmptyView()
        }
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style

    // MARK: - Private Methods

    private func isIncluded(button: POButtonViewModel) -> Bool {
        button.role != .cancel
    }
}

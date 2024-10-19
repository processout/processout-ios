//
//  DynamicCheckoutPaymentMethodButtonsView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct DynamicCheckoutPaymentMethodButtonsView: View {

    /// Available actions.
    let buttons: [POButtonViewModel]

    // MARK: - View

    var body: some View {
        let buttons = self.buttons.filter(isIncluded)
        VStack(spacing: POSpacing.small) {
            ForEach(buttons) { button in
                Button(button.title, action: button.action)
                    .buttonStyle(
                        forPrimaryRole: style.actionsContainer.primary, fallback: style.actionsContainer.secondary
                    )
                    .buttonViewModel(button)
            }
        }
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

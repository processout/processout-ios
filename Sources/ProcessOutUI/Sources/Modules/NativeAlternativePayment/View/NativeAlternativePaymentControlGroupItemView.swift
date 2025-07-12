//
//  NativeAlternativePaymentControlGroupItemView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.06.2025.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct NativeAlternativePaymentControlGroupItemView: View {

    let item: NativeAlternativePaymentViewModelItem.ControlGroup

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: POSpacing.space12) {
            ForEach(item.content) { item in
                Button.create(with: item).buttonStyle(
                    forPrimaryRole: style.actionsContainer.primary,
                    fallback: style.actionsContainer.secondary
                )
            }
        }
        .padding(.top, POSpacing.space12)
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}

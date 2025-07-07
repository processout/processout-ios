//
//  NativeAlternativePaymentGroupItemView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.06.2025.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct NativeAlternativePaymentGroupItemView: View {

    let item: NativeAlternativePaymentViewModelItem.Group

    @Binding
    private(set) var focusedItemId: AnyHashable?

    // MARK: - View

    var body: some View {
        GroupBox {
            ForEach(item.items) { item in
                NativeAlternativePaymentItemView(item: item, focusedItemId: $focusedItemId)
            }
        } label: {
            if let label = item.label {
                Text(label)
            }
        }
        .poGroupBoxStyle(style.groupBoxStyle)
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}

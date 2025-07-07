//
//  NativeAlternativePaymentTitleItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
@MainActor
struct NativeAlternativePaymentTitleItemView: View {

    let item: NativeAlternativePaymentViewModelItem.Title

    // MARK: - View

    var body: some View {
        HStack(spacing: POSpacing.space16) {
            Text(item.text)
                .textStyle(style.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let icon = item.icon {
                icon.resizable().scaledToFit().frame(maxHeight: 24)
            }
        }
        .padding(.bottom, POSpacing.space12)
        .preference(key: NativeAlternativePaymentViewSeparatorVisibilityPreferenceKey.self, value: true)
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}

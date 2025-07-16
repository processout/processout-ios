//
//  NativeAlternativePaymentTitleItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@MainActor
struct NativeAlternativePaymentTitleItemView: View {

    let item: NativeAlternativePaymentViewModelItem.Title

    // MARK: - View

    var body: some View {
        HStack(spacing: POSpacing.space16) {
            if let icon = item.icon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 24)
            }
            Text(item.text)
                .textStyle(style.title)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.bottom, POSpacing.space12)
        .preference(key: NativeAlternativePaymentViewSeparatorVisibilityPreferenceKey.self, value: true)
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}

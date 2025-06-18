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

    var body: some View {
        Text(item.text)
            .textStyle(style.title)
            .padding(.bottom, POSpacing.large)
            .preference(key: NativeAlternativePaymentViewSeparatorVisibilityPreferenceKey.self, value: true)
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}

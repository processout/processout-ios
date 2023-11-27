//
//  NativeAlternativePaymentTitleItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct NativeAlternativePaymentTitleItemView: View {

    let item: NativeAlternativePaymentViewModelItem.Title

    var body: some View {
        VStack(alignment: .leading, spacing: POSpacing.small) {
            Text(item.text)
                .textStyle(style.title)
                .padding(.horizontal, POSpacing.large)
            Divider()
                .frame(height: 1)
                .overlay(style.separatorColor)
        }
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}

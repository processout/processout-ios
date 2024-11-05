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
    let horizontalPadding: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: POSpacing.large) {
            Text(item.text)
                .textStyle(style.title)
                .padding(.horizontal, horizontalPadding)
            Rectangle()
                .fill(style.separatorColor)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}

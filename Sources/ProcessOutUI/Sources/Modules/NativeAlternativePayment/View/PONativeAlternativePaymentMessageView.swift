//
//  PONativeAlternativePaymentMessageView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.05.2025.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct PONativeAlternativePaymentMessageView: View {

    let item: NativeAlternativePaymentViewModelItem.Message

    // MARK: - View

    var body: some View {
        if #available(iOS 16.0, *) {
            LabeledContent {
                POMarkdown(item.text)
            } label: {
                if let title = item.title {
                    Text(title)
                }
            }
        } else {
            POMarkdown(item.text)
        }
    }
}

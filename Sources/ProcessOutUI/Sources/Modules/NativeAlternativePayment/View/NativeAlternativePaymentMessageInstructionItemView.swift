//
//  NativeAlternativePaymentMessageInstructionItemView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.06.2025.
//

import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

struct NativeAlternativePaymentMessageInstructionItemView: View {

    let item: NativeAlternativePaymentViewModelItem.MessageInstruction

    // MARK: - View

    var body: some View {
        if let title = item.title {
            POLabeledContent {
                POCopyButton(
                    configuration: .init(
                        value: item.value,
                        copyTitle: String(resource: .NativeAlternativePayment.Button.copy),
                        copiedTitle: String(resource: .NativeAlternativePayment.Button.copied)
                    )
                )
                .controlSize(.small)
                .controlWidth(.regular)
                .buttonStyle(POAnyButtonStyle(erasing: style.actionsContainer.secondary))
            } label: {
                Text(title)
                Text(item.value)
            }
            .poLabeledContentStyle(style.labeledContentStyle)
        } else {
            POMarkdown(item.value)
                .textStyle(style.bodyText)
        }
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}

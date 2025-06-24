//
//  NativeAlternativePaymentMessageInstructionItemView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.06.2025.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct NativeAlternativePaymentMessageInstructionItemView: View {

    let item: NativeAlternativePaymentViewModelItem.MessageInstruction

    // MARK: - View

    var body: some View {
        // todo(andrii-vysotskyi): support style customization and update localizations
        if let title = item.title {
            POLabeledContent {
                POCopyButton(
                    configuration: .init(value: item.value, copyTitle: "Copy", copiedTitle: "Copied!")
                )
                .backport.poControlSize(.small)
                .controlWidth(.regular)
                .buttonStyle(POAnyButtonStyle(erasing: style.actionsContainer.secondary))
            } label: {
                POMarkdown(title)
            }
        } else {
            POMarkdown(item.value)
        }
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}

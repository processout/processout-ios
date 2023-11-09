//
//  CardUpdateItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 07.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct CardUpdateItemView: View {

    let item: CardUpdateViewModelItem

    @Binding
    private(set) var focusedInputId: AnyHashable?

    var body: some View {
        switch item {
        case .input(let item):
            POTextField(
                text: item.$value, prompt: item.placeholder, trailingView: item.icon?.accessibility(hidden: true)
            )
            .backport.focused($focusedInputId, equals: item.id)
            .backport.onSubmit(item.onSubmit)
            .poKeyboardType(.asciiCapableNumberPad)
            .inputStyle(style.input)
            .controlInvalid(item.isInvalid)
            .disabled(!item.isEnabled)
            .animation(.default, value: item.icon == nil)
        case .error(let errorItem):
            Text(errorItem.description)
                .textStyle(style.errorDescription)
        case .progress:
            ProgressView()
                .poProgressViewStyle(style.progressView)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Private Properties

    @Environment(\.cardUpdateStyle)
    private var style
}

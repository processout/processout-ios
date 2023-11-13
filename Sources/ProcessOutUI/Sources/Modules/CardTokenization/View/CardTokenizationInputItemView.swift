//
//  CardTokenizationInputItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 31.10.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct CardTokenizationInputItemView: View {

    let item: CardTokenizationViewModelState.InputItem

    @Binding
    private(set) var focusedInputId: AnyHashable?

    var body: some View {
        POTextField(
            text: item.$value,
            formatter: item.formatter,
            prompt: item.placeholder,
            trailingView: item.icon?.accessibility(hidden: true)
        )
        .backport.focused($focusedInputId, equals: item.id)
        .backport.onSubmit(item.onSubmit)
        .backport.submitLabel(.next)
        .poTextContentType(item.contentType)
        .poKeyboardType(item.keyboard)
        .inputStyle(style.input)
        .controlInvalid(item.isInvalid)
        .animation(.default, value: item.icon == nil)
    }

    // MARK: - Private Properties

    @Environment(\.cardTokenizationStyle)
    private var style
}

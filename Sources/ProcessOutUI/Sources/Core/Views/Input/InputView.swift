//
//  InputView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 13.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct InputView: View {

    let item: InputViewModel

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
        .poTextContentType(item.contentType)
        .poKeyboardType(item.keyboard)
        .controlInvalid(item.isInvalid)
        .disabled(!item.isEnabled)
        .animation(.default, value: item.icon == nil)
    }
}

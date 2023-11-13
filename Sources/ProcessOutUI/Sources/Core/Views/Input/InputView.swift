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

    let viewModel: InputViewModel

    @Binding
    private(set) var focusedInputId: AnyHashable?

    var body: some View {
        POTextField(
            text: viewModel.$value,
            formatter: viewModel.formatter,
            prompt: viewModel.placeholder,
            trailingView: viewModel.icon?.accessibility(hidden: true)
        )
        .backport.focused($focusedInputId, equals: viewModel.id)
        .backport.onSubmit(viewModel.onSubmit)
        .poTextContentType(viewModel.contentType)
        .poKeyboardType(viewModel.keyboard)
        .controlInvalid(viewModel.isInvalid)
        .disabled(!viewModel.isEnabled)
        .animation(.default, value: viewModel.icon == nil)
    }
}

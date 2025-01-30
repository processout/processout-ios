//
//  TextField+ViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.11.2024.
//

import SwiftUI

@available(iOS 14, *)
extension POTextField where Trailing == AnyView {

    public static func create(
        with viewModel: POTextFieldViewModel, focusedInputId: Binding<AnyHashable?>
    ) -> some View {
        TextFieldWrapper(viewModel: viewModel, focusedInputId: focusedInputId)
    }
}

@available(iOS 14, *)
@MainActor
private struct TextFieldWrapper: View {

    let viewModel: POTextFieldViewModel

    @Binding
    private(set) var focusedInputId: AnyHashable?

    // MARK: - View

    var body: some View {
        POTextField(
            text: viewModel.$value,
            formatter: viewModel.formatter,
            prompt: viewModel.placeholder,
            trailingView: viewModel.icon?.accessibility(hidden: true)
        )
        .backport.focused($focusedInputId, equals: viewModel.id)
        .backport.onSubmit(viewModel.onSubmit)
        .backport.submitLabel(viewModel.submitLabel)
        .poTextContentType(viewModel.contentType)
        .poKeyboardType(viewModel.keyboard)
        .controlInvalid(viewModel.isInvalid)
        .disabled(!viewModel.isEnabled)
        .animation(.default, value: viewModel.icon == nil)
    }
}

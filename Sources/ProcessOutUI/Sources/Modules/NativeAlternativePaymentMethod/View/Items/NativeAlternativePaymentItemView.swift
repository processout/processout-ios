//
//  NativeAlternativePaymentItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct NativeAlternativePaymentItemView: View {

    let item: NativeAlternativePaymentViewModelItem

    @Binding
    private(set) var focusedInputId: AnyHashable?

    var body: some View {
        switch item {
        case .title(let item):
            NativeAlternativePaymentTitleItemView(item: item)
        case .input(let item):
            InputView(viewModel: item, focusedInputId: $focusedInputId).inputStyle(style.input)
                .padding(.horizontal, POSpacing.large)
        case .codeInput(let item):
            POCodeField(length: item.length, text: item.$value)
                .backport.focused($focusedInputId, equals: item.id)
                .controlInvalid(item.isInvalid)
                .disabled(!item.isEnabled)
                .inputStyle(style.codeInput)
                .padding(.horizontal, POSpacing.large)
        case .picker(let pickerItem):
            POPicker(pickerItem.options, selection: pickerItem.$selectedOptionId) { option in
                Text(option.title)
            }
            .modify(when: pickerItem.preferrsInline) { view in
                let style = PORadioGroupPickerStyle(radioButtonStyle: POAnyButtonStyle(erasing: style.radioButton))
                view.pickerStyle(style)
            }
            .pickerStyle(POMenuPickerStyle(inputStyle: style.input))
            .padding(.horizontal, POSpacing.large)
        case .progress:
            ProgressView().poProgressViewStyle(style.progressView)
        case .submitted(let item):
            NativeAlternativePaymentSubmittedItemView(item: item)
        }
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}

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
    let horizontalPadding: CGFloat

    @Binding
    private(set) var focusedItemId: AnyHashable?

    var body: some View {
        switch item {
        case .title(let item):
            NativeAlternativePaymentTitleItemView(item: item, horizontalPadding: horizontalPadding)
        case .input(let item):
            InputView(viewModel: item, focusedInputId: $focusedItemId)
                .inputStyle(style.input)
                .padding(.horizontal, horizontalPadding)
        case .codeInput(let item):
            POCodeField(text: item.$value, length: item.length)
                .backport.focused($focusedItemId, equals: item.id)
                .controlInvalid(item.isInvalid)
                .allowsHitTesting(item.isEnabled)
                .inputStyle(style.codeInput)
                .padding(.horizontal, horizontalPadding)
        case .picker(let pickerItem):
            POPicker(pickerItem.options, selection: pickerItem.$selectedOptionId) { option in
                Text(option.title)
            }
            .modify(when: pickerItem.preferrsInline) { view in
                let style = PORadioGroupPickerStyle(radioButtonStyle: POAnyButtonStyle(erasing: style.radioButton))
                view.pickerStyle(style)
            }
            .pickerStyle(POMenuPickerStyle(inputStyle: style.input))
            .padding(.horizontal, horizontalPadding)
        case .progress:
            ProgressView()
                .poProgressViewStyle(style.progressView)
                .padding(.horizontal, horizontalPadding)
        case .submitted(let item):
            NativeAlternativePaymentSubmittedItemView(item: item, horizontalPadding: horizontalPadding)
        }
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}

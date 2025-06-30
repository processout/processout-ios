//
//  NativeAlternativePaymentPickerItemView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.06.2025.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct NativeAlternativePaymentPickerItemView: View {

    let item: NativeAlternativePaymentViewModelItem.Picker

    // MARK: - View

    var body: some View {
        POPicker(selection: item.$selectedOptionId) {
            ForEach(item.options) { option in
                Text(option.title)
            }
        } prompt: {
            Text(item.label)
        }
        .modify(when: item.preferrsInline) { view in
            let style = PORadioGroupPickerStyle(
                radioButtonStyle: POAnyButtonStyle(erasing: style.radioButton),
                inputStyle: style.largeInput
            )
            view.pickerStyle(style)
        }
        .pickerStyle(POMenuPickerStyle(inputStyle: style.input))
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}

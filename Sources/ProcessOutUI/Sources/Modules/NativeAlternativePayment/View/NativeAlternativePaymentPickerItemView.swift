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
        .pickerStyle(pickerStyle)
        .controlInvalid(item.isInvalid)
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style

    // MARK: - Private Methods

    private var pickerStyle: any POPickerStyle {
        if item.preferrsInline {
            PORadioGroupPickerStyle(
                radioButtonStyle: POAnyButtonStyle(erasing: style.radioButton),
                inputStyle: style.largeInput
            )
        } else {
            POMenuPickerStyle(inputStyle: style.input)
        }
    }
}

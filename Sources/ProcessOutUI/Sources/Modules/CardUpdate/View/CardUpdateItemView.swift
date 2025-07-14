//
//  CardUpdateItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 07.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@MainActor
struct CardUpdateItemView: View {

    let item: CardUpdateViewModelItem

    @Binding
    private(set) var focusedInputId: AnyHashable?

    var body: some View {
        switch item {
        case .input(let item):
            POTextField.create(with: item, focusedInputId: $focusedInputId)
                .inputStyle(style.input)
        case .picker(let pickerItem):
            POPicker(selection: pickerItem.$selectedOptionId) {
                ForEach(pickerItem.options) { option in
                    Text(option.title)
                }
            }
            .modify(when: pickerItem.prefersInline) { view in
                let style = PORadioGroupPickerStyle(
                    radioButtonStyle: POAnyButtonStyle(erasing: style.radioButton),
                    inputStyle: style.input
                )
                view.pickerStyle(style)
            }
            .pickerStyle(POMenuPickerStyle(inputStyle: style.input))
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

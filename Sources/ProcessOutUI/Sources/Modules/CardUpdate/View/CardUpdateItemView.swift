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
            InputView(viewModel: item, focusedInputId: $focusedInputId)
                .inputStyle(style.input)
        case .picker(let pickerItem):
            // todo(andrii-vysotskyi): use injected style when scheme selection is public
            POPicker(pickerItem.options, selection: pickerItem.$selectedOptionId) { option in
                Text(option.title)
            }
            .modify(when: pickerItem.preferrsInline) { view in
                let style = PORadioGroupPickerStyle(radioButtonStyle: .radio)
                view.pickerStyle(style)
            }
            .pickerStyle(POMenuPickerStyle(inputStyle: .medium))
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

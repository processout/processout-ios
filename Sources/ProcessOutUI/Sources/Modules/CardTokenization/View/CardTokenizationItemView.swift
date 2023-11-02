//
//  CardTokenizationItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.10.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct CardTokenizationItemView: View {

    let item: CardTokenizationViewModelState.Item

    /// The distance between adjacent items.
    let spacing: CGFloat

    @Binding
    private(set) var focusedInputId: AnyHashable?

    var body: some View {
        switch item {
        case .input(let inputItem):
            CardTokenizationInputItemView(item: inputItem, focusedInputId: $focusedInputId)
        case .picker(let pickerItem):
            POPicker(pickerItem.options, selection: pickerItem.$selectedOptionId) { option in
                Text(option.title)
            }
            .modify(when: pickerItem.preferrsInline) { view in
                let style = PORadioGroupPickerStyle(radioButtonStyle: POAnyButtonStyle(erasing: style.radioButton))
                view.pickerStyle(style)
            }
            .pickerStyle(POMenuPickerStyle(inputStyle: style.input))
        case .error(let errorItem):
            Text(errorItem.description)
                .textStyle(style.errorDescription)
        case .group(let groupItem):
            HStack(spacing: spacing) {
                ForEach(groupItem.items) { item in
                    CardTokenizationItemView(item: item, spacing: spacing, focusedInputId: $focusedInputId)
                }
            }
            .backport.geometryGroup()
            .animation(.default, value: groupItem.items.map(\.id))
        }
    }

    // MARK: - Private Properties

    @Environment(\.cardTokenizationStyle)
    private var style
}

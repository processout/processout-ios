//
//  CardTokenizationItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.10.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
@MainActor
struct CardTokenizationItemView: View {

    let item: CardTokenizationViewModelState.Item

    @Binding
    private(set) var focusedInputId: AnyHashable?

    var body: some View {
        switch item {
        case .input(let inputItem):
            POTextField.create(with: inputItem, focusedInputId: $focusedInputId)
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
        case .toggle(let toggleItem):
            Toggle(toggleItem.title, isOn: toggleItem.$isSelected)
                .poToggleStyle(style.toggle)
        case .button(let buttonItem):
            Button.create(with: buttonItem)
                .buttonStyle(forPrimaryRole: style.actionsContainer.primary, fallback: style.actionsContainer.secondary)
                .controlSize(.small)
        case .error(let errorItem):
            Text(errorItem.description)
                .textStyle(style.errorDescription)
        case .group(let groupItem):
            HStack(spacing: POSpacing.small) {
                ForEach(groupItem.items) { item in
                    CardTokenizationItemView(item: item, focusedInputId: $focusedInputId)
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

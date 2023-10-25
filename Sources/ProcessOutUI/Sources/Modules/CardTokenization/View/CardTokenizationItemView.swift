//
//  CardTokenizationItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.10.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

struct CardTokenizationItemView: View {

    let item: CardTokenizationViewModelState.Item

    /// The distance between adjacent items.
    let spacing: CGFloat

    @Binding
    private(set) var focusedInputId: AnyHashable?

    var body: some View {
        switch item {
        case .input(let inputItem):
            POTextField(
                text: inputItem.$value,
                formatter: inputItem.formatter,
                prompt: inputItem.placeholder,
                trailingView: inputItem.icon?.accessibility(hidden: true)
            )
            .backport.focused($focusedInputId, equals: inputItem.id)
            .backport.onSubmit(inputItem.onSubmit)
            .poTextContentType(inputItem.contentType)
            .poKeyboardType(inputItem.keyboard)
            .inputStyle(style.input)
            .animation(.default, value: inputItem.icon == nil)
            .accessibility(identifier: inputItem.accessibilityId)
        case .picker(let pickerItem):
            POPicker(pickerItem.options, selection: pickerItem.$selectedOptionId) { option in
                Text(option.title)
            }
            .pickerStyle(PORadioGroupPickerStyle(radioButtonStyle: POAnyButtonStyle(erasing: style.radioButton)))
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

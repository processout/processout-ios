//
//  NativeAlternativePaymentItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI
@_spi(PO) import ProcessOut

@available(iOS 14, *)
@MainActor
struct NativeAlternativePaymentItemView: View {

    let item: NativeAlternativePaymentViewModelItem

    @Binding
    private(set) var focusedItemId: AnyHashable?

    var body: some View {
        switch item {
        case .title(let item):
            NativeAlternativePaymentTitleItemView(item: item)
        case .input(let item):
            POTextField.create(with: item, focusedInputId: $focusedItemId)
                .inputStyle(style.input)
        case .codeInput(let item):
            POCodeField(text: item.$value, length: item.length)
                .backport.focused($focusedItemId, equals: item.id)
                .controlInvalid(item.isInvalid)
                .inputStyle(style.codeInput)
        case .phoneNumberInput(let item):
            view(for: item)
        case .picker(let item):
            view(for: item)
        case .progress:
            ProgressView()
                .poProgressViewStyle(style.progressView)
                .frame(maxWidth: .infinity)
        case .messageInstruction(let item):
            view(for: item)
        case .image(let item):
            Image(uiImage: item.image)
        case .group(let group):
            view(for: group)
        case .button(let item):
            Button.create(with: item)
                .buttonStyle(forPrimaryRole: style.actionsContainer.primary, fallback: style.actionsContainer.secondary)
        case .message(let item):
            // todo(andrii-vysotskyi): support style customization
            POMessageView(message: item)
        case .confirmationProgress(let item):
            NativeAlternativePaymentConfirmationProgressItemView(item: item)
        case .success(let item):
            NativeAlternativePaymentSuccessItemView(item: item)
        }
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style

    // MARK: - Private Methods

    private func view(for item: NativeAlternativePaymentViewModelItem.Picker) -> some View {
        POPicker(selection: item.$selectedOptionId) {
            ForEach(item.options) { option in
                Text(option.title)
            }
        }
        .modify(when: item.preferrsInline) { view in
            let style = PORadioGroupPickerStyle(
                radioButtonStyle: POAnyButtonStyle(erasing: style.radioButton),
                inputStyle: style.input
            )
            view.pickerStyle(style)
        }
        .pickerStyle(POMenuPickerStyle(inputStyle: style.input))
    }

    private func view(for item: NativeAlternativePaymentViewModelItem.PhoneNumberInput) -> some View {
        POPhoneNumberField(
            phoneNumber: item.$value,
            countryPrompt: {
                Text(verbatim: "Country")
            },
            numberPrompt: item.prompt
        )
        .phoneNumberFieldTerritories(item.territories)
        .phoneNumberFieldStyle(
            PODefaultPhoneNumberFieldStyle(country: POMenuPickerStyle(inputStyle: style.input), number: .automatic)
        )
        .inputStyle(style.input)
        .controlInvalid(item.isInvalid)
    }

    private func view(for group: NativeAlternativePaymentViewModelItem.Group) -> some View {
        GroupBox {
            VStack {
                ForEach(group.items) { item in
                    NativeAlternativePaymentItemView(item: item, focusedItemId: $focusedItemId)
                }
            }
        } label: {
            if let label = group.label {
                Text(label)
            }
        }
        .groupBoxStyle(.poAutomatic)
    }

    @ViewBuilder
    private func view(for item: NativeAlternativePaymentViewModelItem.MessageInstruction) -> some View {
        if let title = item.title {
            POLabeledContent {
                POCopyButton(
                    configuration: .init(value: item.value, copyTitle: "Copy", copiedTitle: "Copied!")
                )
                .backport.poControlSize(.small)
                .controlWidth(.regular)
                .buttonStyle(POAnyButtonStyle(erasing: style.actionsContainer.secondary))
            } label: {
                POMarkdown(title)
            }
        } else {
            POMarkdown(item.value)
        }
    }
}

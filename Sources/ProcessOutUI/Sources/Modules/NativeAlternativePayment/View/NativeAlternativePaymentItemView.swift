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
            POCodeField(text: item.$value, length: item.length) {
                Text(item.label)
            }
            .backport.focused($focusedItemId, equals: item.id)
            .inputStyle(style.largeInput)
            .controlInvalid(item.isInvalid)
            .poKeyboardType(item.keyboard)
        case .phoneNumberInput(let item):
            NativeAlternativePaymentPhoneItemView(item: item, focusedItemId: $focusedItemId)
        case .toggle(let item):
            Toggle(item.title, isOn: item.$isSelected)
                .poToggleStyle(style.toggle)
                .controlInvalid(item.isInvalid)
        case .picker(let item):
            NativeAlternativePaymentPickerItemView(item: item)
        case .progress:
            ProgressView()
                .poProgressViewStyle(style.progressView)
                .padding(.vertical, POSpacing.large)
                .frame(maxWidth: .infinity)
        case .messageInstruction(let item):
            NativeAlternativePaymentMessageInstructionItemView(item: item)
        case .image(let item):
            VStack {
                Image(uiImage: item.image)
                if let viewModel = item.actionButton {
                    Button.create(with: viewModel)
                        .buttonStyle(POAnyButtonStyle(erasing: style.actionsContainer.secondary))
                        .controlSize(.small)
                }
            }
            .padding(.horizontal, POSpacing.space48)
        case .sizingGroup(let item):
            VStack(alignment: .leading, spacing: POSpacing.space12) {
                ForEach(item.content) { item in
                    NativeAlternativePaymentItemView(item: item, focusedItemId: $focusedItemId)
                }
            }
        case .group(let group):
            NativeAlternativePaymentGroupItemView(item: group, focusedItemId: $focusedItemId)
        case .button(let item):
            Button.create(with: item)
                .buttonStyle(forPrimaryRole: style.actionsContainer.primary, fallback: style.actionsContainer.secondary)
        case .message(let item):
            POMessageView(message: item)
                .messageViewStyle(style.messageView)
        case .confirmationProgress(let item):
            NativeAlternativePaymentConfirmationProgressItemView(item: item)
        case .success(let item):
            NativeAlternativePaymentSuccessItemView(item: item)
        }
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}

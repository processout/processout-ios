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
            NativeAlternativePaymentPhoneItemView(item: item, focusedItemId: $focusedItemId)
        case .toggle(let item):
            Toggle(item.title, isOn: item.$isSelected)
                .poToggleStyle(style.toggle)
        case .picker(let item):
            NativeAlternativePaymentPickerItemView(item: item)
        case .progress:
            ProgressView()
                .poProgressViewStyle(style.progressView)
                .frame(maxWidth: .infinity)
        case .messageInstruction(let item):
            NativeAlternativePaymentMessageInstructionItemView(item: item)
        case .image(let item):
            VStack {
                Image(uiImage: item.image)
                if let viewModel = item.actionButton {
                    Button.create(with: viewModel)
                        .buttonStyle(POAnyButtonStyle(erasing: style.actionsContainer.secondary))
                        .backport.poControlSize(.small)
                }
            }
            .padding(.horizontal, POSpacing.space48)
        case .group(let group):
            NativeAlternativePaymentGroupItemView(item: group, focusedItemId: $focusedItemId)
        case .controlGroup(let group):
            NativeAlternativePaymentControlGroupItemView(item: group)
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
}

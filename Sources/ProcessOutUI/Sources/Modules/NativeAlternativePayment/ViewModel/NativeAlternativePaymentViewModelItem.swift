//
//  NativeAlternativePaymentViewModelItem.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

indirect enum NativeAlternativePaymentViewModelItem {

    struct Title: Identifiable, Hashable {

        /// Item identifier.
        let id: AnyHashable

        /// Title text.
        let text: String
    }

    struct Picker: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Available options.
        let options: [PickerOption]

        /// Currently selected option id.
        @Binding var selectedOptionId: String?

        /// Boolean value indicating whether selection is valid.
        let isInvalid: Bool

        /// Boolean flag indicating whether inline style is preferred.
        let preferrsInline: Bool
    }

    struct PickerOption: Identifiable {

        /// Option id.
        let id: String

        /// Option title.
        let title: String
    }

    struct CodeInput: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Code input length.
        let length: Int

        /// Current parameter's value text.
        @Binding var value: String

        /// Boolean value indicating whether value is valid.
        let isInvalid: Bool
    }

    struct PhoneNumberInput: Identifiable {

        let id: AnyHashable

        /// Available territories.
        let territories: [POPhoneNumber.Territory]

        /// Current parameter's value.
        @Binding var value: POPhoneNumber

        /// Prompt.
        let prompt: String

        /// Boolean value indicating whether value is valid.
        let isInvalid: Bool
    }

    struct MessageInstruction: Identifiable, Hashable {

        let id: AnyHashable

        /// Message title if any.
        let title: String?

        /// Message text.
        let value: String
    }

    struct Image: Identifiable, Hashable {

        let id: AnyHashable

        /// Image illustrating action.
        let image: UIImage
    }

    struct Group {

        let id: AnyHashable

        /// Group label.
        let label: String?

        /// Items
        let items: [NativeAlternativePaymentViewModelItem]
    }

    /// Loading indicator.
    case progress

    /// Static title..
    case title(Title)

    /// Text input field.
    case input(POTextFieldViewModel)

    /// Code input field with fixed length.
    case codeInput(CodeInput)

    /// Phone number input with selectable territories.
    case phoneNumberInput(PhoneNumberInput)

    /// Picker with multiple options.
    case picker(Picker)

    /// Static message with optional title.
    case messageInstruction(MessageInstruction)

    /// Group of items displayed together.
    case group(Group)

    /// Image to illustrate an action.
    case image(Image)

    /// Action button.
    case button(POButtonViewModel)

    /// Informational message.
    case message(POMessage)
}

extension NativeAlternativePaymentViewModelItem: Identifiable {

    var id: AnyHashable {
        switch self {
        case .progress:
            return Constants.progressId
        case .title(let item):
            return item.id
        case .input(let item):
            return item.id
        case .codeInput(let item):
            return item.id
        case .phoneNumberInput(let item):
            return item.id
        case .picker(let item):
            return item.id
        case .message(let item):
            return item.id
        case .image(let item):
            return item.id
        case .group(let item):
            return item.id
        case .button(let item):
            return item.id
        case .messageInstruction(let item):
            return item.id
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let progressId = UUID().uuidString
    }
}

extension NativeAlternativePaymentViewModelItem: AnimationIdentityProvider {

    var animationIdentity: AnyHashable {
        switch self {
        case .title(let item):
            return item
        default:
            return id
        }
    }
}

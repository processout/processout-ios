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

    typealias Input = POTextFieldViewModel

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

        /// Boolean value indicating whether value is valid.
        let isInvalid: Bool
    }

    // no longer needed
    struct Submitted: Identifiable, Hashable {

        /// Item identifier.
        let id: AnyHashable

        /// Title text.
        let title: String?

        /// Payment provider logo.
        let logoImage: UIImage?

        /// Message markdown.
        let message: String

        /// Boolean value indicating whether layout should be vertically compact.
        let isMessageCompact: Bool

        /// Image illustrating action.
        let image: UIImage?

        /// Boolean value that indicates whether payment is already captured.
        let isCaptured: Bool

        /// Defines whether progress view should be hidden or not.
        let isProgressViewHidden: Bool
    }

    struct Message: Identifiable, Hashable {

        let id: AnyHashable

        /// Message title if any.
        let title: String?

        /// Message text.
        let text: String
    }

    struct Image: Identifiable, Hashable {

        let id: AnyHashable

        /// Image illustrating action.
        let image: UIImage
    }

    typealias Button = POButtonViewModel

    struct Group {

        let id: AnyHashable

        let label: String?

        /// Items
        let items: [NativeAlternativePaymentViewModelItem]
    }

    case progress

    case title(Title)

    case input(Input)

    case codeInput(CodeInput)

    case phoneNumberInput(PhoneNumberInput)

    case picker(Picker)

    case submitted(Submitted)

    case message(Message)

    case group(Group)

    case image(Image)

    case button(Button)
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
        case .submitted(let item):
            return item.id
        case .message(let item):
            return item.id
        case .image(let item):
            return item.id
        case .group(let item):
            return item.id
        case .button(let item):
            return item.id
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let progressId = UUID().uuidString
    }
}

extension NativeAlternativePaymentViewModelSection: AnimationIdentityProvider {

    var animationIdentity: AnyHashable {
        [id, items.map(animationIdentity), error]
    }

    // MARK: - Private Methods

    private func animationIdentity(of item: NativeAlternativePaymentViewModelItem) -> AnyHashable {
        switch item {
        case .title(let item):
            return item
        case .submitted(let item):
            return item
        default:
            return item.id
        }
    }
}

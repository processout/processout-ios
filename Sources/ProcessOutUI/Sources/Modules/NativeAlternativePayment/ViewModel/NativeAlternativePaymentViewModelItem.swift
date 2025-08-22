//
//  NativeAlternativePaymentViewModelItem.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import SwiftUI
import ProcessOut
@_spi(PO) import ProcessOutCoreUI

indirect enum NativeAlternativePaymentViewModelItem {

    struct Title: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Icon resource.
        let icon: SwiftUI.Image?

        /// Title text.
        let text: String
    }

    struct Picker: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Picker label.
        let label: String

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

        /// Code field label.
        let label: String

        /// Boolean value indicating whether value is valid.
        let isInvalid: Bool

        /// Keyboard type.
        let keyboard: UIKeyboardType
    }

    struct PhoneNumberInput: Identifiable {

        let id: AnyHashable

        /// Available territories.
        let territories: [POPhoneNumber.Territory]

        /// Current parameter's value.
        @Binding var value: POPhoneNumber

        /// Country picker prompt.
        let countryPrompt: String

        /// Prompt.
        let prompt: String

        /// Boolean value indicating whether value is valid.
        let isInvalid: Bool
    }

    struct ToggleItem: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Title.
        let title: String

        /// Defines whether item is currently selected.
        @Binding var isSelected: Bool

        /// Boolean value indicating whether value is valid.
        let isInvalid: Bool
    }

    struct MessageInstruction: Identifiable, Hashable {

        let id: AnyHashable

        /// Message title if any.
        let title: String?

        /// Message text.
        let value: String

        /// Copy button title.
        let copyTitle: String

        /// Copied button title.
        let copiedTitle: String
    }

    struct Image: Identifiable {

        let id: AnyHashable

        /// Image illustrating action.
        let image: UIImage

        /// Action button associated with this image if any.
        let actionButton: POButtonViewModel?
    }

    struct Group {

        let id: AnyHashable

        /// Group label.
        let label: String?

        /// Items
        let items: [NativeAlternativePaymentViewModelItem]
    }

    struct SizingGroup {

        let id: AnyHashable

        /// Items
        let content: [NativeAlternativePaymentViewModelItem]
    }

    struct ConfirmationProgress {

        /// The title of the first step.
        let firstStepTitle: String

        /// The title of the second step.
        let secondStepTitle: String

        /// A closure that returns a description for the second step based on the
        /// remaining time string.
        let secondStepDescription: (String) -> String

        /// Date components formatter.
        let formatter: DateComponentsFormatter

        /// Date indicating when confirmation is estimated to end.
        let estimatedCompletionDate: Date
    }

    struct Success {

        /// Success title.
        let title: String

        /// Success description.
        let description: String?
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

    /// Toggle item.
    case toggle(ToggleItem)

    /// Picker with multiple options.
    case picker(Picker)

    /// Static message with optional title.
    case messageInstruction(MessageInstruction)

    /// Group of items displayed together.
    case group(Group)

    /// Image to illustrate an action.
    case image(Image)

    /// Allow to alter components spacing.
    case sizingGroup(SizingGroup)

    /// Action button.
    case button(POButtonViewModel)

    /// Informational message.
    case message(POMessage)

    /// Payment confirmation progress details.
    case confirmationProgress(ConfirmationProgress)

    /// Payment success item.
    case success(Success)
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
        case .toggle(let item):
            return item.id
        case .picker(let item):
            return item.id
        case .message(let item):
            return item.id
        case .image(let item):
            return item.id
        case .sizingGroup(let item):
            return item.id
        case .group(let item):
            return item.id
        case .button(let item):
            return item.id
        case .messageInstruction(let item):
            return item.id
        case .confirmationProgress:
            return Constants.confirmationProgressId
        case .success:
            return Constants.successId
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let progressId = UUID().uuidString
        static let confirmationProgressId = UUID().uuidString
        static let successId = UUID().uuidString
    }
}

extension NativeAlternativePaymentViewModelItem: AnimationIdentityProvider {

    var animationIdentity: AnyHashable {
        switch self {
        case .title(let item):
            return item.text
        case .sizingGroup(let item):
            return item.content.map(\.animationIdentity)
        case .group(let item):
            return item.items.map(\.animationIdentity)
        default:
            return id
        }
    }
}

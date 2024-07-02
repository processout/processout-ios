//
//  NativeAlternativePaymentViewModelItem.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import SwiftUI

enum NativeAlternativePaymentViewModelItem {

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

    typealias Input = InputViewModel

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

    struct Submitted: Identifiable, Hashable {

        /// Item identifier.
        let id: AnyHashable

        /// Title text.
        let title: String?

        /// Payment provider logo.
        let logoImage: UIImage?

        /// Message markdown.
        let message: String

        /// Image illustrating action.
        let image: UIImage?

        /// Boolean value that indicates whether payment is already captured.
        let isCaptured: Bool

        /// Defines whether progress view should be hidden or not.
        let isProgressViewHidden: Bool
    }

    case progress, title(Title), input(Input), codeInput(CodeInput), picker(Picker), submitted(Submitted)
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
        case .picker(let item):
            return item.id
        case .submitted(let item):
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

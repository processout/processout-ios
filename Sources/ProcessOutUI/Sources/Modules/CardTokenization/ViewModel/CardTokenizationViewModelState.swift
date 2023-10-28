//
//  CardTokenizationViewModelState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.07.2023.
//

import Foundation
import SwiftUI
@_spi(PO) import ProcessOutCoreUI

struct CardTokenizationViewModelState {

    struct Section: Identifiable {

        /// Section id.
        let id: AnyHashable

        /// Section title if any.
        let title: String?

        /// Section items.
        let items: [Item]
    }

    enum Item {
        case group(GroupItem), input(InputItem), picker(PickerItem), error(ErrorItem)
    }

    struct GroupItem: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Group items.
        let items: [Item]
    }

    struct InputItem: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Current parameter's value text.
        /// - NOTE: View model doesn't own value of input item so binding is used instead.
        @Binding var value: String

        /// Parameter's placeholder.
        let placeholder: String

        /// Boolean value indicating whether value is valid.
        let isInvalid: Bool

        /// Input icon.
        let icon: Image?

        /// Formatter to use to format value if any.
        let formatter: Formatter?

        /// Keyboard type.
        let keyboard: UIKeyboardType

        /// Text content type.
        let contentType: UITextContentType?

        /// Accessibility identifier useful for testing.
        let accessibilityId: String

        /// Action to perform when the user submits a value to this input.
        let onSubmit: () -> Void
    }

    struct PickerItem: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Availale options.
        let options: [PickerItemOption]

        /// Currently selected option id.
        @Binding var selectedOptionId: String?

        /// Boolean flag indicating whether inline style is preferred.
        let preferrsInline: Bool
    }

    struct PickerItemOption: Identifiable {

        /// Option id.
        let id: String

        /// Option title.
        let title: String
    }

    struct ErrorItem: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Error description.
        let description: String
    }

    /// Screen title.
    let title: String?

    /// Available items.
    let sections: [Section]

    /// Available actions.
    let actions: [POActionsContainerActionViewModel]

    /// Currently focused input identifier.
    var focusedInputId: AnyHashable?
}

extension CardTokenizationViewModelState {

    static var idle: Self {
        Self(title: nil, sections: [], actions: [], focusedInputId: nil)
    }
}

extension CardTokenizationViewModelState.Item: Identifiable {

    var id: AnyHashable {
        switch self {
        case .input(let inputItem):
            return inputItem.id
        case .picker(let pickerItem):
            return pickerItem.id
        case .group(let groupItem):
            return groupItem.id
        case .error(let errorItem):
            return errorItem.id
        }
    }
}

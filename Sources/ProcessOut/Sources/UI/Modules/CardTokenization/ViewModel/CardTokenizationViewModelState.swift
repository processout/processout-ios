//
//  CardTokenizationViewModelState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.07.2023.
//

import Foundation
import UIKit

struct CardTokenizationViewModelState {

    struct InputValue: Hashable {

        /// Current parameter's value text.
        @ReferenceWrapper
        var text: String

        /// Boolean value indicating whether value is valid.
        @ReferenceWrapper
        var isInvalid: Bool

        /// Boolean value indicating whether input is currently focused.
        @ReferenceWrapper
        var isFocused: Bool
    }

    struct TitleItem: Hashable {

        /// Title text.
        let text: String
    }

    struct InputItem: Hashable {

        /// Parameter's placeholder.
        let placeholder: String?

        /// Value details.
        let value: InputValue

        /// Formatter to use to format value if any.
        let formatter: Formatter?

        /// Boolean value indicates whether input should be compact in UI.
        let isCompact: Bool

        /// Keyboard type.
        let keyboard: UIKeyboardType

        /// Text content type.
        let contentType: UITextContentType?

        /// Submit items value.
        @ImmutableNullHashable
        var submit: () -> Void
    }

    struct ErrorItem: Hashable {

        /// Error description.
        let description: String
    }

    enum Item: Hashable {
        case title(TitleItem), input(InputItem), error(ErrorItem)
    }

    struct SectionIdentifier: Hashable {

        /// Section id.
        let id: String

        /// Section title if any.
        let title: String?
    }

    struct Section {

        /// Identifier.
        let id: SectionIdentifier

        /// Section items.
        let items: [Item]
    }

    typealias Action = ActionsContainerActionViewModel
    typealias Actions = ActionsContainerViewModel

    /// Available items.
    let sections: [Section]

    /// Available actions.
    let actions: Actions

    /// Boolean value indicating whether editing is allowed.
    let isEditingAllowed: Bool
}

extension CardTokenizationViewModelState {

    static var idle: Self {
        Self(sections: [], actions: .init(primary: nil, secondary: nil), isEditingAllowed: false)
    }
}

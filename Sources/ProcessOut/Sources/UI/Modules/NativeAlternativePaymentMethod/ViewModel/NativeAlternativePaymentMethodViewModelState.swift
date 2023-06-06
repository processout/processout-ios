//
//  NativeAlternativePaymentMethodViewModelState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.04.2023.
//

import UIKit

enum NativeAlternativePaymentMethodViewModelState {

    typealias ParameterType = PONativeAlternativePaymentMethodParameter.ParameterType

    struct TitleItem: Hashable {

        /// Title text.
        let text: String
    }

    struct RadioButtonItem: Hashable {

        /// Current value.
        let value: String

        /// Indicates whether radio button is selected.
        let isSelected: Bool

        /// Boolean value indicating whether value is valid.
        let isInvalid: Bool

        /// Closure to invoke when radio button is selected.
        @ImmutableNullHashable
        var select: () -> Void
    }

    struct PickerOption: Hashable {

        /// Option name.
        let name: String

        /// Indicates whether option is currently selected.
        let isSelected: Bool

        /// Closure to invoke when option is selected.
        @ImmutableNullHashable
        var select: () -> Void
    }

    struct PickerItem: Hashable {

        /// Current value.
        let value: String

        /// Boolean value indicating whether value is valid.
        let isInvalid: Bool

        /// Available options.
        let options: [PickerOption]
    }

    struct InputValue: Hashable {

        /// Current parameter's value text.
        @ReferenceWrapper
        var text: String

        /// Boolean value indicating whether value is valid.
        @ReferenceWrapper
        var isInvalid: Bool

        /// Boolean value indicating whether editing is allowed.
        @ReferenceWrapper
        var isEditingAllowed: Bool
    }

    struct CodeInputItem: Hashable {

        /// Code input length.
        let length: Int

        /// Value details.
        let value: InputValue
    }

    struct InputItem: Hashable {

        /// Parameter type.
        let type: ParameterType

        /// Parameter's placeholder.
        let placeholder: String?

        /// Value details.
        let value: InputValue

        /// Boolean value indicating whether parameter is last in a chain.
        let isLast: Bool

        /// Formatter to use to format value if any.
        let formatter: Formatter?
    }

    struct ErrorItem: Hashable {

        /// Error description.
        let description: String
    }

    struct SubmittedItem: Hashable {

        /// Message.
        let message: String

        /// Gateway's logo image.
        let logoImage: UIImage?

        /// Image illustrating action.
        let image: UIImage?

        /// Boolean value that indicates whether payment is already captured.
        let isCaptured: Bool
    }

    enum Item: Hashable {
        case loader
        case title(TitleItem)
        case input(InputItem)
        case codeInput(CodeInputItem)
        case radio(RadioButtonItem)
        case picker(PickerItem)
        case error(ErrorItem)
        case submitted(SubmittedItem)
    }

    enum SectionDecoration {
        case normal, success
    }

    struct SectionIdentifier: Hashable {

        /// Section id.
        let id: String?

        /// Section title if any.
        let title: String?

        /// Section decoration.
        let decoration: SectionDecoration?
    }

    struct Section {

        /// Identifier.
        let id: SectionIdentifier

        /// Section items.
        let items: [Item]
    }

    struct Action {

        /// Action title.
        let title: String

        /// Boolean value indicating whether action is enabled.
        let isEnabled: Bool

        /// Boolean value indicating whether action associated with button is currently running.
        let isExecuting: Bool

        /// Action handler.
        let handler: () -> Void
    }

    struct Actions {

        /// Primary action.
        let primary: Action?

        /// Secondary action.
        let secondary: Action?
    }

    struct Started {

        /// Available items.
        let sections: [Section]

        /// Available actions.
        let actions: Actions

        /// Boolean value indicating whether editing is allowed.
        let isEditingAllowed: Bool
    }

    case idle, started(Started)
}

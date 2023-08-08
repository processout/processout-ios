//
//  NativeAlternativePaymentMethodViewModelState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.04.2023.
//

import UIKit

enum NativeAlternativePaymentMethodViewModelState {

    typealias TitleItem = CollectionViewTitleViewModel

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

        /// Indicates whether input should be centered.
        let isCentered: Bool
    }

    typealias ParameterType = PONativeAlternativePaymentMethodParameter.ParameterType

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

    typealias ErrorItem = CollectionViewErrorViewModel

    struct SubmittedItem: Hashable {

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

    typealias SectionHeader = CollectionViewSectionHeaderViewModel

    struct SectionIdentifier: Hashable {

        /// Section id.
        let id: String?

        /// Section header if any.
        let header: SectionHeader?

        /// Boolean value indicating whether section items should be laid out tightly.
        let isTight: Bool
    }

    struct Section {

        /// Identifier.
        let id: SectionIdentifier

        /// Section items.
        let items: [Item]
    }

    typealias Action = ActionsContainerActionViewModel
    typealias Actions = ActionsContainerViewModel

    struct Started {

        /// Available items.
        let sections: [Section]

        /// Available actions.
        let actions: Actions

        /// Boolean value indicating whether editing is allowed.
        let isEditingAllowed: Bool

        /// Boolean value that indicates whether payment is already captured.
        let isCaptured: Bool
    }

    case idle, started(Started)
}

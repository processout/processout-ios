//
//  CardTokenizationViewModelState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 20.07.2023.
//

import Foundation
import SwiftUI
import ProcessOut
@_spi(PO) import ProcessOutCoreUI

// TODOs:
// - Allow selecting card co-scheme when authorizing invoice or assigning token

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
        case group(GroupItem)
        case input(InputItem)
        case picker(PickerItem)
        case toggle(ToggleItem)
        case button(ButtonItem)
        case error(ErrorItem)
    }

    struct GroupItem: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Group items.
        let items: [Item]
    }

    struct PickerItem: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Available options.
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

    struct ToggleItem: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Title.
        let title: String

        /// Defines whether item is currently selected.
        @Binding var isSelected: Bool
    }

    struct ErrorItem: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Error description.
        let description: String
    }

    struct CardScanner: Identifiable {

        let id: String

        /// Card scanner configuration.
        let configuration: POCardScannerConfiguration

        /// Card scanner delegate.
        weak var delegate: POCardScannerDelegate?

        /// Completion.
        let completion: (Result<POScannedCard, POFailure>) -> Void
    }

    typealias InputItem = POTextFieldViewModel
    typealias ButtonItem = POButtonViewModel

    /// Screen title.
    let title: String?

    /// Available items.
    let sections: [Section]

    /// Available actions.
    let actions: [POButtonViewModel]

    /// Currently focused input identifier.
    var focusedInputId: AnyHashable?

    /// Card scanner.
    var cardScanner: CardScanner?
}

extension CardTokenizationViewModelState: AnimationIdentityProvider {

    static var idle: Self {
        Self(title: nil, sections: [], actions: [], focusedInputId: nil)
    }

    var animationIdentity: AnyHashable {
        let sectionsIdentity = sections.map { section in
            [section.id, section.items.map(\.id)]
        }
        return [sectionsIdentity, AnyHashable(actions.map(\.id))]
    }
}

extension CardTokenizationViewModelState.Item: Identifiable {

    var id: AnyHashable {
        switch self {
        case .input(let item):
            return item.id
        case .picker(let item):
            return item.id
        case .toggle(let item):
            return item.id
        case .group(let item):
            return item.id
        case .button(let item):
            return item.id
        case .error(let item):
            return item.id
        }
    }
}

//
//  CardTokenizationViewModelState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 20.07.2023.
//

import Foundation
import SwiftUI
@_spi(PO) import ProcessOutCoreUI

// TODOs:
// - Support scanning card details with camera
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
        case group(GroupItem), input(InputItem), picker(PickerItem), toggle(ToggleItem), error(ErrorItem)
    }

    struct GroupItem: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Group items.
        let items: [Item]
    }

    typealias InputItem = InputViewModel

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

    /// Screen title.
    let title: String?

    /// Available items.
    let sections: [Section]

    /// Available actions.
    let actions: [POButtonViewModel]

    /// Currently focused input identifier.
    var focusedInputId: AnyHashable?
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
        case .error(let item):
            return item.id
        }
    }
}

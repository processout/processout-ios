//
//  DynamicCheckoutViewModelSection.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 07.03.2024.
//

struct DynamicCheckoutViewModelSection: Identifiable {

    /// Section ID.
    let id: String

    /// Items.
    let items: [DynamicCheckoutViewModelItem]

    /// Defines whether view should display separators.
    let areSeparatorsVisible: Bool

    /// Defines whether view should render bezels (frame) around section content.
    let areBezelsVisible: Bool
}

extension DynamicCheckoutViewModelSection {

    /// Section's animation identity. For now only properties that may affect layout
    /// changes are part of identity.
    ///
    /// - NOTE: When this property changes view should be updated with
    /// explicit animation.
    var animationIdentity: AnyHashable {
        [id, items.map(\.id), AnyHashable(areSeparatorsVisible), AnyHashable(areBezelsVisible)]
    }
}

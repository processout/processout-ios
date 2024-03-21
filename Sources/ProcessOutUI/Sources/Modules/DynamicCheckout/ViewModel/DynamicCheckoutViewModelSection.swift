//
//  DynamicCheckoutViewModelSection.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 07.03.2024.
//

struct DynamicCheckoutViewModelSection {

    /// Section title.
    let title: String?

    /// Items.
    let items: [DynamicCheckoutViewModelItem]

    /// Defines whether view should display separators.
    let areSeparatorsVisible: Bool
}

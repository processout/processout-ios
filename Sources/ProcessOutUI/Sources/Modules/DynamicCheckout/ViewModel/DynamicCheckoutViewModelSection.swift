//
//  DynamicCheckoutViewModelSection.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 07.03.2024.
//

struct DynamicCheckoutViewModelSection: Identifiable {

    /// Section ID.
    let id: String

    /// Section title.
    let title: String?

    /// Items.
    let items: [DynamicCheckoutViewModelItem]

    /// Defines whether view should display separators.
    let areSeparatorsVisible: Bool
}

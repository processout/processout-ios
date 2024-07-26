//
//  CardUpdateViewModelSection.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.01.2024.
//

import Foundation

struct CardUpdateViewModelSection: Identifiable {

    /// Section id.
    let id: AnyHashable

    /// Section title if any.
    let title: String?

    /// Section items.
    let items: [CardUpdateViewModelItem]
}

@available(*, unavailable)
extension CardUpdateViewModelSection: Sendable { }

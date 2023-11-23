//
//  NativeAlternativePaymentViewModelSection.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

struct NativeAlternativePaymentViewModelSection: Identifiable {

    /// Section id.
    let id: AnyHashable

    /// Section title if any.
    let title: String

    /// Indicates whether section header should be centered.
    let isCentered: Bool

    /// Section items.
    let items: [NativeAlternativePaymentViewModelItem]
}

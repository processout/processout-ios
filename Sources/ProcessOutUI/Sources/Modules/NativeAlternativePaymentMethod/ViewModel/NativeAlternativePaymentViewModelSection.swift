//
//  NativeAlternativePaymentViewModelSection.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

struct NativeAlternativePaymentViewModelSection: Identifiable {

    /// Section id.
    let id: AnyHashable

    /// Indicates whether section header should be centered.
    let isCentered: Bool

    /// Section title if any.
    let title: String?

    /// Section items.
    let items: [NativeAlternativePaymentViewModelItem]

    /// Error description if any.
    let error: String?
}

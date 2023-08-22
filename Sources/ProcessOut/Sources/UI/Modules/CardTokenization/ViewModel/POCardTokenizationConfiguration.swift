//
//  POCardTokenizationConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 01.08.2023.
//

import Foundation

/// A configuration object that defines a card tokenization module behaves.
/// Use `nil` as a value for a nullable property to indicate that default value should be used.
@_spi(PO)
public struct POCardTokenizationConfiguration {

    /// Custom title. Use empty string to hide title.
    public let title: String?

    /// Indicates if the input for entering the cardholder name should be displayed. Defaults to `true`.
    public let isCardholderNameInputVisible: Bool

    /// Primary action text, such as "Submit".
    public let primaryActionTitle: String?

    /// Primary action text, such as "Cancel". Use empty string to hide button.
    public let cancelActionTitle: String?

    /// Card billing address.
    public let billingAddress: POContact?

    /// Boolean flag determines whether user will be aksed to select scheme if co-scheme is available.
    /// Until feature is fully ready this is hardcoded to `false`.
    let isSchemeSelectionAllowed: Bool

    public init(
        title: String? = nil,
        isCardholderNameInputVisible: Bool = true,
        primaryActionTitle: String? = nil,
        cancelActionTitle: String? = nil,
        billingAddress: POContact? = nil
    ) {
        self.title = title
        self.isCardholderNameInputVisible = isCardholderNameInputVisible
        self.primaryActionTitle = primaryActionTitle
        self.cancelActionTitle = cancelActionTitle
        self.billingAddress = billingAddress
        isSchemeSelectionAllowed = false
    }
}

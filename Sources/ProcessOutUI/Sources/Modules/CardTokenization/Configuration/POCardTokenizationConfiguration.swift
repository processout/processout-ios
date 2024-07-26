//
//  POCardTokenizationConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 01.08.2023.
//

import Foundation
import ProcessOut

/// A configuration object that defines a card tokenization module behaves.
/// Use `nil` as a value for a nullable property to indicate that default value should be used.
public struct POCardTokenizationConfiguration: Sendable {

    /// Custom title. Use empty string to hide title.
    public let title: String?

    /// Indicates if the input for entering the cardholder name should be displayed. Defaults to `true`.
    public let isCardholderNameInputVisible: Bool

    /// Indicates whether card's CVC should be collected.
    public let shouldCollectCvc: Bool

    /// Primary action text, such as "Submit". Use empty string to hide button.
    public let primaryActionTitle: String?

    /// Primary action text, such as "Cancel". Use empty string to hide button.
    public let cancelActionTitle: String?

    /// Card billing address collection configuration.
    public let billingAddress: POBillingAddressConfiguration

    /// Metadata related to the card.
    public let metadata: [String: String]?

    /// Boolean flag determines whether user will be asked to select scheme if co-scheme is available.
    /// Until feature is fully ready this is hardcoded to `false`.
    let isSchemeSelectionAllowed: Bool

    public init(
        title: String? = nil,
        isCardholderNameInputVisible: Bool = true,
        shouldCollectCvc: Bool = true,
        primaryActionTitle: String? = nil,
        cancelActionTitle: String? = nil,
        billingAddress: POBillingAddressConfiguration = .init(),
        metadata: [String: String]? = nil
    ) {
        self.title = title
        self.isCardholderNameInputVisible = isCardholderNameInputVisible
        self.shouldCollectCvc = shouldCollectCvc
        self.primaryActionTitle = primaryActionTitle
        self.cancelActionTitle = cancelActionTitle
        self.billingAddress = billingAddress
        self.metadata = metadata
        isSchemeSelectionAllowed = false
    }
}

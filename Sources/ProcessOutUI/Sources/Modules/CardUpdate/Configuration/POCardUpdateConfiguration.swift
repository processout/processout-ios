//
//  POCardUpdateConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

/// A configuration object that defines how a card update module behaves.
/// Use `nil` as a value for a nullable property to indicate that default value should be used.
public struct POCardUpdateConfiguration {

    /// Card id that needs to be updated.
    public let cardId: String

    /// Allows to provide card information that will be visible in UI. It is also possible to inject
    /// it dynamically using ``POCardUpdateDelegate/cardInformation(cardId:)``.
    public let cardInformation: POCardUpdateInformation?

    /// Custom title. Use empty string to hide title.
    public let title: String?

    /// Primary action text, such as "Submit".
    public let primaryActionTitle: String?

    /// Primary action text, such as "Cancel". Use empty string to hide button.
    public let cancelActionTitle: String?

    public init(
        cardId: String,
        cardInformation: POCardUpdateInformation? = nil,
        title: String? = nil,
        primaryActionTitle: String? = nil,
        cancelActionTitle: String? = nil
    ) {
        self.cardId = cardId
        self.cardInformation = cardInformation
        self.title = title
        self.primaryActionTitle = primaryActionTitle
        self.cancelActionTitle = cancelActionTitle
    }
}

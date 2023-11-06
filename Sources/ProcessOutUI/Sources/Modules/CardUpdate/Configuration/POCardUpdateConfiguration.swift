//
//  POCardUpdateConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

/// A configuration object that defines how a card update module behaves.
/// Use `nil` as a value for a nullable property to indicate that default value should be used.
public struct POCardUpdateConfiguration {

    /// Custom title. Use empty string to hide title.
    public let title: String?

    /// Primary action text, such as "Submit".
    public let primaryActionTitle: String?

    /// Primary action text, such as "Cancel". Use empty string to hide button.
    public let cancelActionTitle: String?

    public init(
        title: String? = nil,
        primaryActionTitle: String? = nil,
        cancelActionTitle: String? = nil
    ) {
        self.title = title
        self.primaryActionTitle = primaryActionTitle
        self.cancelActionTitle = cancelActionTitle
    }
}
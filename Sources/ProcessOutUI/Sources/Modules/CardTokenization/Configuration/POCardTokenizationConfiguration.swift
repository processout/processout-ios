//
//  POCardTokenizationConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 01.08.2023.
//

import Foundation
import SwiftUI
import ProcessOut

/// A configuration object that defines a card tokenization module behaves.
/// Use `nil` as a value for a nullable property to indicate that default value should be used.
public struct POCardTokenizationConfiguration: Sendable {

    /// Button configuration.
    public struct SubmitButton: Sendable {

        /// Button title, such as "Pay". Pass `nil` title to use default value.
        public let title: String?

        /// Button icon. Pass `nil` to remove icon.
        public let icon: Image?

        public init(title: String? = nil, icon: Image? = nil) {
            self.title = title
            self.icon = icon
        }
    }

    /// Cancel button configuration.
    public struct CancelButton: Sendable {

        /// Button title. Pass `nil` title to use default value.
        public let title: String?

        /// Button icon. Pass `nil` to remove icon.
        public let icon: Image?

        /// When property is set implementation asks user to confirm cancel.
        public let confirmation: POConfirmationDialogConfiguration?

        /// Creates cancel button configuration.
        public init(title: String? = nil, icon: Image? = nil, confirmation: POConfirmationDialogConfiguration? = nil) {
            self.title = title
            self.icon = icon
            self.confirmation = confirmation
        }
    }

    /// Custom title. Use empty string to hide title.
    public let title: String?

    /// Indicates if the input for entering the cardholder name should be displayed. Defaults to `true`.
    public let shouldCollectCardholderName: Bool

    /// Indicates whether card's CVC should be collected.
    public let shouldCollectCvc: Bool

    /// Submit button configuration.
    public let submitButton: SubmitButton

    /// Cancel button configuration.
    public let cancelButton: CancelButton?

    /// Card billing address collection configuration.
    public let billingAddress: POBillingAddressConfiguration

    /// Indicates whether the UI should display a control that allows the user
    /// to choose whether to save their card details for future payments.
    public let isSavingAllowed: Bool

    /// Metadata related to the card.
    public let metadata: [String: String]?

    /// Boolean flag determines whether user will be asked to select scheme if co-scheme is available.
    @_spi(PO)
    public var isSchemeSelectionAllowed: Bool = false

    public init(
        title: String? = nil,
        shouldCollectCardholderName: Bool = true,
        shouldCollectCvc: Bool = true,
        billingAddress: POBillingAddressConfiguration = .init(),
        isSavingAllowed: Bool = false,
        submitButton: SubmitButton = .init(),
        cancelButton: CancelButton? = nil,
        metadata: [String: String]?
    ) {
        self.title = title
        self.shouldCollectCardholderName = shouldCollectCardholderName
        self.shouldCollectCvc = shouldCollectCvc
        self.submitButton = submitButton
        self.cancelButton = cancelButton
        self.billingAddress = billingAddress
        self.isSavingAllowed = isSavingAllowed
        self.metadata = metadata
    }
}

extension POCardTokenizationConfiguration {

    @available(*, deprecated, renamed: "shouldCollectCardholderName")
    public var isCardholderNameInputVisible: Bool {
        shouldCollectCardholderName
    }

    /// Primary action text, such as "Submit".
    @available(*, deprecated, renamed: "primaryButton.title")
    public var primaryActionTitle: String? {
        submitButton.title
    }

    /// Primary action text, such as "Cancel". Use empty string to hide button.
    @available(*, deprecated, renamed: "cancelButton.title")
    public var cancelActionTitle: String? {
        cancelButton == nil ? "" : cancelButton?.title
    }

    @available(*, deprecated)
    @_disfavoredOverload
    public init(
        title: String? = nil,
        isCardholderNameInputVisible: Bool = true,
        shouldCollectCvc: Bool = true,
        primaryActionTitle: String? = nil,
        cancelActionTitle: String? = nil,
        billingAddress: POBillingAddressConfiguration = .init(),
        isSavingAllowed: Bool = false,
        metadata: [String: String]? = nil
    ) {
        self.title = title
        self.shouldCollectCardholderName = isCardholderNameInputVisible
        self.shouldCollectCvc = shouldCollectCvc
        self.submitButton = .init(title: primaryActionTitle)
        self.cancelButton = cancelActionTitle?.isEmpty == true ? nil : .init(title: cancelActionTitle)
        self.billingAddress = billingAddress
        self.isSavingAllowed = isSavingAllowed
        self.metadata = metadata
    }
}

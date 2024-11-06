//
//  POCardTokenizationConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 01.08.2023.
//

// swiftlint:disable nesting

import Foundation
import SwiftUI
import ProcessOut

/// A configuration object that defines a card tokenization module behaves.
/// Use `nil` as a value for a nullable property to indicate that default value should be used.
@MainActor
@preconcurrency
public struct POCardTokenizationConfiguration: Sendable {

    /// Billing address collection configuration.
    @MainActor
    @preconcurrency
    public struct BillingAddress: Sendable {

        @available(*, deprecated, message: "Use POBillingAddressCollectionMode directly.")
        public typealias CollectionMode = POBillingAddressCollectionMode

        /// Billing address collection mode.
        public let mode: POBillingAddressCollectionMode

        /// List of ISO country codes that is supported for the billing address. When nil, all countries are provided.
        public let countryCodes: Set<String>?

        /// Default address information.
        public let defaultAddress: POContact?

        /// Whether the values included in ``POBillingAddressConfiguration/defaultAddress`` should be attached to the
        /// card, this includes fields that aren't displayed in the form.
        ///
        /// If `false` (the default), those values will only be used to prefill the corresponding fields in the form.
        public let attachDefaultsToPaymentMethod: Bool

        /// Creates billing address configuration.
        public init(
            mode: POBillingAddressCollectionMode = .automatic,
            countryCodes: Set<String>? = nil,
            defaultAddress: POContact? = nil,
            attachDefaultsToPaymentMethod: Bool = false
        ) {
            self.countryCodes = countryCodes
            self.mode = mode
            self.defaultAddress = defaultAddress
            self.attachDefaultsToPaymentMethod = attachDefaultsToPaymentMethod
        }
    }

    /// Text field configuration.
    @MainActor
    @preconcurrency
    public struct TextField: Sendable {

        /// Text providing users with guidance on what to type into the text field.
        public let prompt: String?

        /// Text field icon.
        public let icon: AnyView?

        public init(prompt: String? = nil, icon: AnyView? = nil) {
            self.prompt = prompt
            self.icon = icon
        }
    }

    /// Submit button configuration.
    @MainActor
    @preconcurrency
    public struct SubmitButton: Sendable {

        /// Button title, such as "Pay". Pass `nil` title to use default value.
        public let title: String?

        /// Button icon. Pass `nil` title to use default value.
        public let icon: AnyView?

        public init(title: String? = nil, icon: AnyView? = nil) {
            self.title = title
            self.icon = icon
        }
    }

    /// Cancel button configuration.
    @MainActor
    @preconcurrency
    public struct CancelButton: Sendable {

        /// Button title. Pass `nil` title to use default value.
        public let title: String?

        /// Button icon. Pass `nil` title to use default value.
        public let icon: AnyView?

        /// When property is set implementation asks user to confirm cancel.
        public let confirmation: POConfirmationDialogConfiguration?

        /// Creates cancel button configuration.
        public init(
            title: String? = nil, icon: AnyView? = nil, confirmation: POConfirmationDialogConfiguration? = nil
        ) {
            self.title = title
            self.icon = icon
            self.confirmation = confirmation
        }
    }

    /// Custom title. Use empty string to hide title.
    public let title: String?

    /// Configuration for the cardholder name text field. Set to `nil` if cardholder name collection is not required.
    public let cardholderName: TextField?

    /// Configuration for the card number text field.
    public let cardNumber: TextField

    /// Configuration for the expiration date text field.
    public let expirationDate: TextField

    /// Configuration for the CVC text field. Set to `nil` if CVC collection is not required.
    public let cvc: TextField?

    /// Boolean flag determines whether user will be asked to select scheme if co-scheme is available.
    @_spi(PO)
    public var isSchemeSelectionAllowed: Bool = false

    /// Card billing address collection configuration.
    public let billingAddress: BillingAddress

    /// Indicates whether the UI should display a control that allows the user
    /// to choose whether to save their card details for future payments.
    public let isSavingAllowed: Bool

    /// Submit button configuration.
    public let submitButton: SubmitButton

    /// Cancel button configuration.
    public let cancelButton: CancelButton?

    /// Metadata related to the card.
    public let metadata: [String: String]?

    public init(
        title: String? = nil,
        cardholderName: TextField? = .init(),
        cardNumber: TextField = .init(),
        expirationDate: TextField = .init(),
        cvc: TextField? = .init(),
        billingAddress: BillingAddress = .init(),
        isSavingAllowed: Bool = false,
        submitButton: SubmitButton = .init(),
        cancelButton: CancelButton? = .init(),
        metadata: [String: String]? = nil
    ) {
        self.title = title
        self.cardholderName = cardholderName
        self.cardNumber = cardNumber
        self.expirationDate = expirationDate
        self.cvc = cvc
        self.submitButton = submitButton
        self.cancelButton = cancelButton
        self.billingAddress = billingAddress
        self.isSavingAllowed = isSavingAllowed
        self.metadata = metadata
    }
}

extension POCardTokenizationConfiguration {

    /// Indicates if the input for entering the cardholder name should be displayed. Defaults to `true`.
    @available(*, deprecated, message: "Use cardholderName object instead.")
    public var isCardholderNameInputVisible: Bool {
        cardholderName != nil
    }

    /// Indicates whether card's CVC should be collected.
    @available(*, deprecated, message: "Use cvc object instead.")
    public var shouldCollectCvc: Bool {
        cvc != nil
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
        self.cardholderName = isCardholderNameInputVisible ? .init() : nil
        self.cardNumber = .init()
        self.expirationDate = .init()
        self.cvc = shouldCollectCvc ? .init() : nil
        self.submitButton = .init(title: primaryActionTitle)
        self.cancelButton = cancelActionTitle?.isEmpty == true ? nil : .init(title: cancelActionTitle)
        self.billingAddress = billingAddress
        self.isSavingAllowed = isSavingAllowed
        self.metadata = metadata
    }
}

// swiftlint:enable nesting

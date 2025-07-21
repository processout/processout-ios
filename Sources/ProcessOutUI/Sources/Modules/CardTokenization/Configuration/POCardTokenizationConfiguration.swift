//
//  POCardTokenizationConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 01.08.2023.
//

// swiftlint:disable nesting

import Foundation
import SwiftUI
@_spi(PO) import ProcessOut

/// A configuration object that defines a card tokenization module behaves.
/// Use `nil` as a value for a nullable property to indicate that default value should be used.
@MainActor
@preconcurrency
public struct POCardTokenizationConfiguration {

    /// Billing address collection configuration.
    @MainActor
    @preconcurrency
    public struct BillingAddress {

        @available(*, deprecated, message: "Use POBillingAddressCollectionMode directly.")
        public typealias CollectionMode = POBillingAddressCollectionMode

        /// Billing address collection mode.
        public let mode: POBillingAddressCollectionMode

        /// List of ISO country codes that is supported for the billing address. When nil, all countries are provided.
        public let countryCodes: Set<String>?

        /// Default address information.
        public let defaultAddress: POContact?

        /// Whether the values included in ``BillingAddress/defaultAddress`` should be attached to the
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

    /// Card scanner configuration.
    @MainActor
    public struct CardScanner {

        /// Card scan button configuration.
        @MainActor
        public struct ScanButton {

            /// Button title, such as "Scan card". Pass `nil` title to use default value.
            public let title: String?

            /// Button icon. Pass `nil` title to use default value.
            public let icon: AnyView?

            public init<Icon: View>(title: String? = nil, icon: Icon? = AnyView?.none) {
                self.title = title
                self.icon = icon.map(AnyView.init(erasing:))
            }
        }

        /// Scan button.
        public let scanButton: ScanButton

        /// Scanner configuration.
        public let configuration: POCardScannerConfiguration

        public init(scanButton: ScanButton = .init(), configuration: POCardScannerConfiguration = .init()) {
            self.scanButton = scanButton
            self.configuration = configuration
        }
    }

    /// Text field configuration.
    @MainActor
    @preconcurrency
    public struct TextField {

        /// Text providing users with guidance on what to type into the text field.
        public let prompt: String?

        /// Text field icon.
        public let icon: AnyView?

        public init<Icon: View>(prompt: String? = nil, icon: Icon? = AnyView?.none) {
            self.prompt = prompt
            self.icon = icon.map(AnyView.init(erasing:))
        }
    }

    /// Submit button configuration.
    @MainActor
    @preconcurrency
    public struct SubmitButton {

        /// Button title, such as "Pay". Pass `nil` title to use default value.
        public let title: String?

        /// Button icon. Pass `nil` title to use default value.
        public let icon: AnyView?

        public init<Icon: View>(title: String? = nil, icon: Icon? = AnyView?.none) {
            self.title = title
            self.icon = icon.map(AnyView.init(erasing:))
        }
    }

    /// Cancel button configuration.
    @MainActor
    @preconcurrency
    public struct CancelButton {

        /// Button title. Pass `nil` title to use default value.
        public let title: String?

        /// Button icon. Pass `nil` title to use default value.
        public let icon: AnyView?

        /// When property is set implementation asks user to confirm cancel.
        public let confirmation: POConfirmationDialogConfiguration?

        /// Creates cancel button configuration.
        public init<Icon: View>(
            title: String? = nil,
            icon: Icon? = AnyView?.none,
            confirmation: POConfirmationDialogConfiguration? = nil
        ) {
            self.title = title
            self.icon = icon.map(AnyView.init(erasing:))
            self.confirmation = confirmation
        }
    }

    /// Preferred scheme selection configuration.
    @MainActor
    public struct PreferredScheme {

        /// Preferred scheme section title. Set `nil` to use default value, or empty string `""` to remove title.
        public let title: String?

        /// Boolean flag indicating whether inline style is preferred, `true` by default.
        public let prefersInline: Bool

        /// Creates scheme selection configuration.
        public init(title: String? = nil, prefersInline: Bool = true) {
            self.title = title
            self.prefersInline = prefersInline
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

    /// Preferred scheme selection configuration.
    /// If value is non-nil user will be asked to select scheme if co-scheme is available.
    public let preferredScheme: PreferredScheme?

    /// Card scanner configuration.
    public let cardScanner: CardScanner?

    /// Card billing address collection configuration.
    public let billingAddress: BillingAddress

    /// Indicates whether the UI should display a control that allows the user
    /// to choose whether to save their card details for future payments.
    public let isSavingAllowed: Bool

    /// Submit button configuration.
    public var submitButton: SubmitButton {
        guard let submitButton = _submitButton else {
            preconditionFailure("Value is not set. Ensure it is provided during initialization.")
        }
        return submitButton
    }

    /// Cancel button configuration.
    public let cancelButton: CancelButton?

    /// Boolean value indicating whether forms controls should be rendered inline.
    public let prefersInlineControls: Bool

    /// Metadata related to the card.
    public let metadata: [String: String]?

    public init(
        title: String? = nil,
        cardholderName: TextField? = .init(),
        cardNumber: TextField = .init(),
        expirationDate: TextField = .init(),
        cvc: TextField? = .init(),
        preferredScheme: PreferredScheme? = .init(),
        cardScanner: CardScanner? = .init(),
        billingAddress: BillingAddress = .init(),
        isSavingAllowed: Bool = false,
        submitButton: SubmitButton? = .init(),
        cancelButton: CancelButton? = .init(),
        prefersInlineControls: Bool = false,
        metadata: [String: String]? = nil
    ) {
        self.title = title
        self.cardholderName = cardholderName
        self.cardNumber = cardNumber
        self.expirationDate = expirationDate
        self.cvc = cvc
        self.preferredScheme = preferredScheme
        self.cardScanner = cardScanner
        self._submitButton = submitButton
        self.cancelButton = cancelButton
        self.billingAddress = billingAddress
        self.isSavingAllowed = isSavingAllowed
        self.prefersInlineControls = prefersInlineControls
        self.metadata = metadata
    }

    // MARK: - Internal

    /// Backing storage for the `submitButton` property.
    ///
    /// This allows `submitButton` to remain a non-optional public API, while
    /// internally supporting optional initialization.
    let _submitButton: SubmitButton? // swiftlint:disable:this identifier_name
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
        cardScanner: CardScanner? = .init(),
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
        self.cardScanner = cardScanner
        self.preferredScheme = .init()
        self._submitButton = .init(title: primaryActionTitle)
        self.cancelButton = cancelActionTitle?.isEmpty == true ? nil : .init(title: cancelActionTitle)
        self.billingAddress = billingAddress
        self.isSavingAllowed = isSavingAllowed
        self.prefersInlineControls = false
        self.metadata = metadata
    }
}

// swiftlint:enable nesting

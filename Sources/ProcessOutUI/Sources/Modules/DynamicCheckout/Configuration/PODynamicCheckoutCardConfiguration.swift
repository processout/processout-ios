//
//  PODynamicCheckoutCardConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import SwiftUI
import ProcessOut

/// Card specific dynamic checkout configuration.
@_spi(PO)
@MainActor
public struct PODynamicCheckoutCardConfiguration {

    /// Card scanner configuration.
    @MainActor
    public struct CardScanner {

        /// Card scan button configuration.
        @MainActor
        public struct ScanButton { // swiftlint:disable:this nesting

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

    /// Billing address collection configuration.
    @MainActor
    public struct BillingAddress {

        /// Default address information.
        public let defaultAddress: POContact?

        /// Whether the values included in ``POBillingAddressConfiguration/defaultAddress`` should be attached to the
        /// card, this includes fields that aren't displayed in the form.
        ///
        /// If `false` (the default), those values will only be used to pre-fill the corresponding fields in the form.
        public let attachDefaultsToPaymentMethod: Bool

        /// Creates billing address configuration.
        public init(defaultAddress: POContact? = nil, attachDefaultsToPaymentMethod: Bool = false) {
            self.defaultAddress = defaultAddress
            self.attachDefaultsToPaymentMethod = attachDefaultsToPaymentMethod
        }
    }

    /// Text field configuration.
    @MainActor
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

    /// Configuration for the cardholder name text field.
    public let cardholderName: TextField

    /// Configuration for the card number text field.
    public let cardNumber: TextField

    /// Configuration for the expiration date text field.
    public let expirationDate: TextField

    /// Configuration for the CVC text field.
    public let cvc: TextField

    /// Preferred scheme selection configuration.
    public let preferredScheme: PreferredScheme

    /// Card scanner configuration.
    public let cardScanner: CardScanner?

    /// Card billing address collection configuration.
    public let billingAddress: BillingAddress

    /// Metadata related to the card.
    public let metadata: [String: String]?

    /// Creates configuration instance.
    public init(
        cardholderName: TextField = .init(),
        cardNumber: TextField = .init(),
        expirationDate: TextField = .init(),
        cvc: TextField = .init(),
        preferredScheme: PreferredScheme = .init(),
        cardScanner: CardScanner = .init(),
        billingAddress: BillingAddress = BillingAddress(),
        metadata: [String: String]? = nil
    ) {
        self.cardholderName = cardholderName
        self.cardNumber = cardNumber
        self.expirationDate = expirationDate
        self.cvc = cvc
        self.preferredScheme = preferredScheme
        self.cardScanner = cardScanner
        self.billingAddress = billingAddress
        self.metadata = metadata
    }
}

//
//  PODynamicCheckoutPaymentMethod.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.03.2024.
//

import Foundation
import UIKit
import PassKit

/// Dynamic checkout payment method description.
///
/// - Warning: New cases may be added in future minor releases.
@_spi(PO)
public enum PODynamicCheckoutPaymentMethod: Sendable {

    // MARK: - Apple Pay

    public struct ApplePay: Decodable, Sendable { // sourcery: AutoCodingKeys

        /// Payment method ID.
        @_spi(PO)
        public var id: String { // sourcery:coding: skip
            configuration.merchantId
        }

        /// Payment flow.
        public let flow: Flow?

        /// Apple pay configuration.
        public let configuration: ApplePayConfiguration // sourcery:coding: key="applepay"
    }

    public struct ApplePayConfiguration: Decodable, Sendable {

        /// Merchant ID.
        public let merchantId: String

        /// The merchant’s two-letter ISO 3166 country code.
        public let countryCode: String

        /// Merchant capabilities.
        @POStringDecodableMerchantCapability
        public var merchantCapabilities: PKMerchantCapability

        /// The payment methods that are supported.
        public let supportedNetworks: Set<POCardScheme>
    }

    // MARK: - Native APM

    public struct NativeAlternativePayment: Decodable, Sendable { // sourcery: AutoCodingKeys

        /// Payment method ID.
        @_spi(PO)
        public var id: String { // sourcery:coding: skip
            configuration.gatewayConfigurationId
        }

        /// Display information.
        public let display: Display

        /// Gateway configuration.
        public let configuration: NativeAlternativePaymentConfiguration // sourcery:coding: key="apm"
    }

    public struct NativeAlternativePaymentConfiguration: Decodable, Sendable {

        /// Gateway configuration ID.
        public let gatewayConfigurationId: String
    }

    // MARK: - APM

    public struct AlternativePayment: Decodable, Sendable { // sourcery: AutoCodingKeys

        /// Payment method ID.
        @_spi(PO)
        public var id: String { // sourcery:coding: skip
            configuration.gatewayConfigurationId
        }

        /// Display information.
        public let display: Display

        /// Payment flow.
        public let flow: Flow?

        /// Payment configuration.
        public let configuration: AlternativePaymentConfiguration // sourcery:coding: key="apm"
    }

    public struct AlternativePaymentConfiguration: Decodable, Sendable {

        /// Gateway configuration ID.
        public let gatewayConfigurationId: String

        /// Redirect URL.
        public let redirectUrl: URL

        /// Indicates whether the UI should display a control (such as a checkbox) that allows
        /// the user to choose whether to save payment details for future payments.
        public let savingAllowed: Bool
    }

    // MARK: - Card

    public struct Card: Decodable, Sendable { // sourcery: AutoCodingKeys

        /// Payment method ID.
        @_spi(PO)
        public let id = "card" // sourcery:coding: skip

        /// Display information.
        public let display: Display

        /// Payment method configuration.
        public let configuration: CardConfiguration // sourcery:coding: key="card"
    }

    public struct CardConfiguration: Decodable, Sendable {

        /// Defines whether user will be asked to select scheme if co-scheme is available.
        let schemeSelectionAllowed: Bool

        /// Indicates whether should collect card CVC.
        public let cvcRequired: Bool

        /// Indicates whether should collect cardholder name.
        public let cardholderNameRequired: Bool

        /// Indicates whether the UI should display a control (such as a checkbox) that allows
        /// the user to choose whether to save their card details for future payments.
        public let savingAllowed: Bool

        /// Card billing address collection configuration.
        public let billingAddress: BillingAddressConfiguration
    }

    public struct BillingAddressConfiguration: Decodable, Sendable {

        /// List of ISO country codes that is supported for the billing address. When nil, all countries are supported.
        public let restrictToCountryCodes: Set<String>?

        /// Billing address collection mode.
        public let collectionMode: POBillingAddressCollectionMode
    }

    // MARK: - Customer Tokens

    public struct CustomerToken: Sendable {

        /// Payment method ID.
        @_spi(PO)
        public var id: String {
            configuration.customerTokenId
        }

        /// Display information.
        public let display: Display

        /// Payment flow.
        public let flow: Flow?

        /// Payment configuration.
        public let configuration: CustomerTokenConfiguration
    }

    public struct CustomerTokenConfiguration: Sendable {

        /// Customer token ID.
        public let customerTokenId: String

        /// Property is set to non-nil value when redirect is required to authorize alternative payment.
        public let redirectUrl: URL?

        /// Indicates whether the user should be able to remove this customer token.
        public let removingAllowed: Bool
    }

    // MARK: - Unknown

    @_spi(PO)
    public struct Unknown: Sendable {

        /// Transient ID assigned to method during decoding.
        @_spi(PO)
        public let id = UUID().uuidString

        /// Unknown payment method raw type.
        public let type: String
    }

    // MARK: - Common

    public struct Display: Decodable, Sendable {

        /// Display name.
        public let name: String

        /// Payment method description.
        public let description: String?

        /// Payment method logo.
        public let logo: POImageRemoteResource

        @POStringCodableColor
        public private(set) var brandColor: UIColor
    }

    public enum Flow: String, Decodable, Sendable {
        case express
    }

    /// Apple Pay.
    case applePay(ApplePay)

    /// Alternative payment.
    case alternativePayment(AlternativePayment)

    /// Native alternative payment.
    case nativeAlternativePayment(NativeAlternativePayment)

    /// Card.
    case card(Card)

    /// Customer token.
    case customerToken(CustomerToken)

    /// Placeholder to allow adding additional payment methods while staying backward compatible.
    /// - Warning: Don't match this case directly, instead use default.
    @_spi(PO)
    case unknown(Unknown)
}

extension PODynamicCheckoutPaymentMethod: Decodable {

    public init(from decoder: any Decoder) throws {
        let type = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .type)
        switch type {
        case "applepay":
            self = .applePay(try ApplePay(from: decoder))
        case "apm":
            do {
                let alternativePayment = try AlternativePayment(from: decoder)
                self = .alternativePayment(alternativePayment)
            } catch {
                let nativeAlternativePayment = try NativeAlternativePayment(from: decoder)
                self = .nativeAlternativePayment(nativeAlternativePayment)
            }
        case "card":
            self = .card(try Card(from: decoder))
        case "card_customer_token", "apm_customer_token":
            let customerToken = try CustomerToken(from: decoder)
            self = .customerToken(customerToken)
        default:
            self = .unknown(Unknown(type: type))
        }
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case type
    }
}

extension PODynamicCheckoutPaymentMethod.CustomerToken: Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        display = try container.decode(
            PODynamicCheckoutPaymentMethod.Display.self, forKey: .display
        )
        flow = try container.decodeIfPresent(
            PODynamicCheckoutPaymentMethod.Flow.self, forKey: .flow
        )
        do {
            configuration = try container.decode(Configuration.self, forKey: .cardCustomerToken)
        } catch {
            configuration = try container.decode(Configuration.self, forKey: .apmCustomerToken)
        }
    }

    // MARK: - Private Nested Types

    private typealias Configuration = PODynamicCheckoutPaymentMethod.CustomerTokenConfiguration

    private enum CodingKeys: String, CodingKey {
        case display, flow, cardCustomerToken, apmCustomerToken
    }
}

extension PODynamicCheckoutPaymentMethod {

    /// Transient method ID.
    @_spi(PO)
    public var id: String {
        switch self {
        case .applePay(let method):
            return method.id
        case .alternativePayment(let method):
            return method.id
        case .nativeAlternativePayment(let method):
            return method.id
        case .card(let method):
            return method.id
        case .customerToken(let method):
            return method.id
        case .unknown(let method):
            return method.id
        }
    }

    /// Display information.
    @_spi(PO)
    public var display: Display? {
        switch self {
        case .alternativePayment(let paymentMethod):
            return paymentMethod.display
        case .nativeAlternativePayment(let paymentMethod):
            return paymentMethod.display
        case .card(let paymentMethod):
            return paymentMethod.display
        case .customerToken(let paymentMethod):
            return paymentMethod.display
        case .applePay, .unknown:
            return nil
        }
    }
}

extension PODynamicCheckoutPaymentMethod.CustomerTokenConfiguration: Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.customerTokenId = try container.decode(String.self, forKey: .customerTokenId)
        self.redirectUrl = try container.decodeIfPresent(URL.self, forKey: .redirectUrl)
        self.removingAllowed = try container.decodeIfPresent(Bool.self, forKey: .removingAllowed) ?? true
    }

    // MARK: - Private Methods

    private enum CodingKeys: String, CodingKey {
        case customerTokenId, redirectUrl, removingAllowed
    }
}

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

    public struct ApplePay: Codable, Sendable { // sourcery: AutoCodingKeys

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

    public struct ApplePayConfiguration: Codable, Sendable {

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

    public struct NativeAlternativePayment: Codable, Sendable { // sourcery: AutoCodingKeys

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

    public struct NativeAlternativePaymentConfiguration: Codable, Sendable {

        /// Gateway configuration ID.
        public let gatewayConfigurationId: String
    }

    // MARK: - APM

    public struct AlternativePayment: Codable, Sendable { // sourcery: AutoCodingKeys

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

    public struct AlternativePaymentConfiguration: Codable, Sendable {

        /// Gateway configuration ID.
        public let gatewayConfigurationId: String

        /// Redirect URL.
        public let redirectUrl: URL

        /// Indicates whether the UI should display a control (such as a checkbox) that allows
        /// the user to choose whether to save payment details for future payments.
        public let savingAllowed: Bool
    }

    // MARK: - Card

    public struct Card: Codable, Sendable { // sourcery: AutoCodingKeys

        /// Payment method ID.
        @_spi(PO)
        public let id = "card" // sourcery:coding: skip

        /// Display information.
        public let display: Display

        /// Payment method configuration.
        public let configuration: CardConfiguration // sourcery:coding: key="card"
    }

    public struct CardConfiguration: Codable, Sendable {

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

    public struct BillingAddressConfiguration: Codable, Sendable {

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

        /// Customer token type.
        public let type: CustomerTokenType

        /// Payment configuration.
        public let configuration: CustomerTokenConfiguration
    }

    public struct CustomerTokenConfiguration: Sendable, Codable {

        /// Customer token ID.
        public let customerTokenId: String

        /// Property is set to non-nil value when redirect is required to authorize alternative payment.
        public let redirectUrl: URL?

        /// Indicates whether the user should be able to remove this customer token.
        public let deletingAllowed: Bool
    }

    public enum CustomerTokenType: String, Sendable, Hashable, Codable {

        /// Customer token represents card.
        case card

        /// Customer token represents alternative payment method.
        case alternativePaymentMethod
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

    public struct Display: Codable, Sendable {

        /// Display name.
        public let name: String

        /// Payment method description.
        public let description: String?

        /// Payment method logo.
        public let logo: POImageRemoteResource

        @POStringCodableColor
        public private(set) var brandColor: UIColor
    }

    public enum Flow: String, Codable, Sendable {
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

extension PODynamicCheckoutPaymentMethod: Codable {

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

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .applePay(let applePay):
            try container.encode("applepay", forKey: .type)
            try applePay.encode(to: encoder)
        case .alternativePayment(let alternativePayment):
            try container.encode("apm", forKey: .type)
            try alternativePayment.encode(to: encoder)
        case .nativeAlternativePayment(let nativeAlternativePayment):
            try container.encode("apm", forKey: .type)
            try nativeAlternativePayment.encode(to: encoder)
        case .card(let card):
            try container.encode("card", forKey: .type)
            try card.encode(to: encoder)
        case .customerToken(let customerToken) where customerToken.type == .card:
            try container.encode("card_customer_token", forKey: .type)
            try customerToken.encode(to: encoder)
        case .customerToken(let customerToken):
            try container.encode("apm_customer_token", forKey: .type)
            try customerToken.encode(to: encoder)
        case .unknown(let unknown):
            try container.encode(unknown.type, forKey: .type)
        }
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case type
    }
}

extension PODynamicCheckoutPaymentMethod.CustomerToken: Codable {

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
            type = .card
        } catch {
            configuration = try container.decode(Configuration.self, forKey: .apmCustomerToken)
            type = .alternativePaymentMethod
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(display, forKey: .display)
        try container.encodeIfPresent(flow, forKey: .flow)
        switch type {
        case .card:
            try container.encode(configuration, forKey: .cardCustomerToken)
        case .alternativePaymentMethod:
            try container.encode(configuration, forKey: .apmCustomerToken)
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

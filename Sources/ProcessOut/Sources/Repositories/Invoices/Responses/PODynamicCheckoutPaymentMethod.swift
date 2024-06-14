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
@_spi(PO)
public enum PODynamicCheckoutPaymentMethod {

    // MARK: - Apple Pay

    public struct ApplePay: Decodable { // sourcery: AutoCodingKeys

        /// Transient ID assigned to method during decoding.
        @_spi(PO)
        public let id = UUID().uuidString // sourcery:coding: skip

        /// Payment flow.
        public let flow: Flow?

        /// Apple pay configuration.
        public let configuration: ApplePayConfiguration // sourcery:coding: key="applepay"
    }

    public struct ApplePayConfiguration: Decodable {

        /// Merchant ID.
        public let merchantId: String

        /// The merchant’s two-letter ISO 3166 country code.
        public let countryCode: String

        /// Merchant capabilities.
        @POStringDecodableMerchantCapability
        public var merchantCapabilities: PKMerchantCapability

        /// The payment methods that are supported.
        public let supportedNetworks: Set<String>
    }

    // MARK: - Native APM

    public struct NativeAlternativePayment: Decodable { // sourcery: AutoCodingKeys

        /// Transient ID assigned to method during decoding.
        @_spi(PO)
        public let id = UUID().uuidString // sourcery:coding: skip

        /// Display information.
        public let display: Display

        /// Gateway configuration.
        public let configuration: NativeAlternativePaymentConfiguration // sourcery:coding: key="apm"
    }

    public struct NativeAlternativePaymentConfiguration: Decodable {

        /// Gateway configuration ID.
        public let gatewayConfigurationUid: String

        /// Gateway name.
        public let gatewayName: String
    }

    // MARK: - APM

    public struct AlternativePayment: Decodable { // sourcery: AutoCodingKeys

        /// Transient ID assigned to method during decoding.
        @_spi(PO)
        public let id = UUID().uuidString // sourcery:coding: skip

        /// Display information.
        public let display: Display

        /// Payment flow.
        public let flow: Flow?

        /// Payment configuration.
        public let configuration: AlternativePaymentConfiguration // sourcery:coding: key="apm"
    }

    public struct AlternativePaymentConfiguration: Decodable {

        /// Redirect URL.
        public let redirectUrl: URL
    }

    // MARK: - Card

    public struct Card: Decodable { // sourcery: AutoCodingKeys

        /// Transient ID assigned to method during decoding.
        @_spi(PO)
        public let id = UUID().uuidString // sourcery:coding: skip

        /// Display information.
        public let display: Display

        /// Payment method configuration.
        public let configuration: CardConfiguration // sourcery:coding: key="card"
    }

    public struct CardConfiguration: Decodable {

        /// Defines whether user will be asked to select scheme if co-scheme is available.
        let allowSchemeSelection: Bool

        /// Indicates whether should collect card CVC.
        public let requireCvc: Bool

        /// Indicates whether should collect cardholder name.
        public let requireCardholderName: Bool

        /// Card billing address collection configuration.
        public let billingAddress: BillingAddressConfiguration
    }

    // MARK: - Unknown

    public struct Unknown {

        /// Transient ID assigned to method during decoding.
        @_spi(PO)
        public let id = UUID().uuidString

        /// Unknown payment method raw type.
        public let type: String
    }

    // MARK: - Common

    public struct Display: Decodable {

        /// Display name.
        public let name: String

        /// Payment method logo.
        public let logo: POImageRemoteResource

        @POStringCodableColor
        public private(set) var brandColor: UIColor
    }

    public struct BillingAddressConfiguration: Decodable {

        /// List of ISO country codes that is supported for the billing address. When nil, all countries are supported.
        public let restrictToCountryCodes: Set<String>?

        /// Billing address collection mode.
        public let collectionMode: POBillingAddressCollectionMode
    }

    public enum Flow: String, Decodable {
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

    /// Unknown payment method.
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
        default:
            self = .unknown(Unknown(type: type))
        }
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case type
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
        case .unknown(let method):
            return method.id
        }
    }
}

//
//  PODynamicCheckoutPaymentMethod.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.03.2024.
//

import Foundation
import UIKit

/// Dynamic checkout payment method description.
public enum PODynamicCheckoutPaymentMethod {

    // MARK: - Apple Pay

    public struct ApplePay: Decodable {

        /// Display information.
        public let display: Display
    }

    // MARK: - APM

    public struct GatewayConfiguration: Decodable {

        /// Gateway ID.
        public let id: String

        /// Gateway subaccount.
        public let subaccount: String
    }

    public struct AlternativePayment: Decodable {

        /// Gateway configuration.
        public let gatewayConfiguration: GatewayConfiguration

        /// Payment flow.
        public let flow: Flow
    }

    // MARK: - Card Customer Token

    public struct CardToken: Decodable {

        /// Customer token ID.
        public let id: String

        /// Card scheme.
        public let scheme: String

        /// Last 4 digits of the card.
        public let last4Digits: String

        /// Card expiration month.
        public let expirationMonth: Int

        /// Card expiration year.
        public let expirationYear: Int
    }

    // MARK: - Common

    public struct Display: Decodable {

        /// Display name.
        public let name: String

        /// Payment method logo.
        public let logo: POImageResource

        @POStringCodableColor
        public private(set) var brandColor: UIColor
    }

    public enum Flow: Decodable {
        case express
    }

    /// Apple Pay.
    case applePay(ApplePay)

    /// Alternative Payment Method.
    case alternativePayment(AlternativePayment)

    /// Card payment.
    case card

    /// Card customer token.
    case cardToken(CardToken)

    /// Unknown payment method.
    case unknown(type: String)
}

extension PODynamicCheckoutPaymentMethod: Decodable {

    public init(from decoder: any Decoder) throws {
        let type = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .type)
        switch type {
        case "applepay":
            let applePay = try ApplePay(from: decoder)
            self = .applePay(applePay)
        case "card":
            self = .card
        case "apm":
            let alternativePayment = try AlternativePayment(from: decoder)
            self = .alternativePayment(alternativePayment)
        default:
            self = .unknown(type: type)
        }
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case type
    }
}

@_spi(PO)
extension PODynamicCheckoutPaymentMethod: Identifiable {

    public var id: String {
        switch self {
        case .applePay:
            return "applepay"
        case .alternativePayment(let alternativePayment):
            let configuration = alternativePayment.gatewayConfiguration
            return "apm_" + configuration.id + "." + configuration.subaccount
        case .card:
            return "card"
        case .cardToken(let token):
            return token.id
        case .unknown(let type):
            return "unknown" + type
        }
    }
}

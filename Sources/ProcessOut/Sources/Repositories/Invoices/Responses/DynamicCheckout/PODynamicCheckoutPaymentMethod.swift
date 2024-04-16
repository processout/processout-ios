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

    public struct ApplePayConfiguration: Decodable {

        /// Merchant ID.
        public let merchantIdentifier: String
    }

    public struct ApplePay: Decodable { // sourcery: AutoCodingKeys

        /// Display information.
        public let display: Display

        /// Payment flow.
        public let flow: Flow?

        /// Apple pay configuration.
        public let configuration: ApplePayConfiguration // sourcery:coding: key="applepay"
    }

    // MARK: - APM

    public struct NativeAlternativePayment: Decodable {

        /// Display information.
        public let display: Display

        /// Gateway configuration.
        public let gatewayConfiguration: GatewayConfiguration
    }

    public struct AlternativePayment: Decodable { // sourcery: AutoCodingKeys

        /// Display information.
        public let display: Display

        /// Payment flow.
        public let flow: Flow?

        /// Gateway configuration.
        public let gatewayConfiguration: GatewayConfiguration

        /// Payment configuration.
        public let configuration: AlternativePaymentConfiguration // sourcery:coding: key="apm"
    }

    public struct AlternativePaymentConfiguration: Decodable {

        /// Redirect URL.
        public let redirectUrl: URL
    }

    public struct GatewayConfiguration: Decodable {

        /// Gateway ID.
        public let id: String

        /// Gateway subaccount.
        public let subaccount: String
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

    public enum Flow: Decodable {
        case express
    }

    /// Apple Pay.
    case applePay(ApplePay)

    /// Alternative payment.
    case alternativePayment(AlternativePayment)

    /// Native alternative payment.
    case nativeAlternativePayment(NativeAlternativePayment)

    /// Card.
    case card

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
        case "apm":
            do {
                let alternativePayment = try AlternativePayment(from: decoder)
                self = .alternativePayment(alternativePayment)
            } catch {
                let nativeAlternativePayment = try NativeAlternativePayment(from: decoder)
                self = .nativeAlternativePayment(nativeAlternativePayment)
            }
        case "card":
            self = .card
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
        case .alternativePayment(let payment):
            return "apm_" + payment.gatewayConfiguration.id + "." + payment.gatewayConfiguration.subaccount
        case .nativeAlternativePayment(let payment):
            return "napm_" + payment.gatewayConfiguration.id + "." + payment.gatewayConfiguration.subaccount
        case .card:
            return "card"
        case .unknown(let type):
            return "unknown" + type
        }
    }
}

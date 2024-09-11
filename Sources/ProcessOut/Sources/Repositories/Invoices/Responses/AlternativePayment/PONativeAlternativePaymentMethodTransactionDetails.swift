//
//  PONativeAlternativePaymentMethodTransactionDetails.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.11.2022.
//

import Foundation

public struct PONativeAlternativePaymentMethodTransactionDetails: Decodable, Sendable {

    /// Payment gateway information.
    public struct Gateway: Sendable {

        /// Name of the payment gateway that can be displayed.
        public let displayName: String

        /// Gateway's logo URL.
        public let logoUrl: URL

        /// Customer action image URL if any.
        public let customerActionImageUrl: URL?

        /// Customer action message markdown. Before using this property check that
        /// `ParameterValues/customerActionMessage` is not set, otherwise use it instead.
        public let customerActionMessage: String?
    }

    /// Invoice details.
    public struct Invoice: Decodable, Sendable {

        /// Invoice amount.
        @POStringCodableDecimal
        public private(set) var amount: Decimal

        /// Invoice currency code.
        public let currencyCode: String
    }

    /// Payment's state.
    public let state: PONativeAlternativePaymentMethodState?

    /// Gateway details.
    public let gateway: Gateway

    /// Invoice details.
    public let invoice: Invoice

    /// Parameters that are expected from user.
    public let parameters: [PONativeAlternativePaymentMethodParameter]

    /// Parameter values.
    public let parameterValues: PONativeAlternativePaymentMethodParameterValues?
}

extension PONativeAlternativePaymentMethodTransactionDetails.Gateway: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displayName = try container.decode(String.self, forKey: .displayName)
        logoUrl = try container.decode(URL.self, forKey: .logoUrl)
        customerActionImageUrl = try container.decodeIfPresent(URL.self, forKey: .customerActionImageUrl)
        // Escapes plain text action message and stores as a markdown.
        customerActionMessage = try container
            .decodeIfPresent(String.self, forKey: .customerActionMessage)
            .map(Self.escaped(plainText:))
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case displayName, logoUrl, customerActionImageUrl, customerActionMessage
    }

    // MARK: - Private Methods

    /// Escapes given plain text so it can be represented as is, in markdown.
    private static func escaped(plainText: String) -> String {
        let specialCharacters = CharacterSet(charactersIn: "\\`*_{}[]()#+-.!")
        var markdown = String()
        markdown.reserveCapacity(plainText.count)
        for character in plainText {
            if character.unicodeScalars.allSatisfy(specialCharacters.contains) {
                markdown += "\\"
            }
            markdown += String(character)
        }
        return markdown
    }
}

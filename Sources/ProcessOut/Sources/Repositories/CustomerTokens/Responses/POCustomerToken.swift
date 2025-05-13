//
//  POCustomerToken.swift
//  ProcessoOut
//
//  Created by Julien.Rodrigues on 02/11/2022.
//

import Foundation

/// Customer tokens (usually just called tokens for short) are objects that associate a payment source such as a
/// card or APM token with a customer.
public struct POCustomerToken: Codable, Sendable {

    /// Customer token verification status.
    public enum VerificationStatus: String, Codable, Sendable {
        case success, pending, failed, notRequested = "not-requested", unknown
    }

    /// String value that uniquely identifies this customer's token.
    public let id: String

    /// Customer from which the token was created.
    public let customerId: String

    /// Gateway configuration that the token is linked to (which can be empty if unused).
    public let gatewayConfigurationId: String?

    /// Card used to create the token.
    public let cardId: String?

    /// Invoice used to verify the token.
    public let invoiceId: String?

    /// Source used to create the token (which will usually be a Card).
    @POTypedRepresentation<String, POCustomerTokenType>
    public private(set) var type: String

    /// Description that will be sent to the tokenization gateway service.
    public let description: String?

    /// If you request verification for the token then this field tracks its status.
    public let verificationStatus: VerificationStatus

    /// Denotes whether or not this is the customer’s default token (the token used when capturing a payment using
    /// the customer’s ID as the source).
    public let isDefault: Bool

    /// For APMs, this is the URL to return to the app after payment is accepted.
    public let returnUrl: URL?

    /// For APMs, this is the URL to return to the app after payment is canceled.
    public let cancelUrl: URL?

    /// Metadata related to the token, in the form of key-value pairs (string - string).
    public let metadata: [String: String]

    /// Date and time when this token was created.
    public let createdAt: Date

    /// Masked version of the payment details (for example, a card number that shows only the
    /// last 4 digits **** **** **** 4242).
    public let summary: String?

    /// Denotes whether or not this token is chargeable.
    public let isChargeable: Bool

    /// If true, this lets you refund or void the invoice manually after the token is verified.
    public let manualInvoiceCancellation: Bool?

    /// If true then you can find the balance for this token.
    public let canGetBalance: Bool?
}

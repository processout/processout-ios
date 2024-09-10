//
//  POCardsService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.03.2023.
//

/// Provides set of methods to tokenize and manipulate cards.
public protocol POCardsService: POService { // sourcery: AutoCompletion

    /// Allows to retrieve card issuer information based on IIN.
    ///
    /// - Parameters:
    ///   - iin: Card issuer identification number. Corresponds to the first 6 or 8 digits of the main card number.
    func issuerInformation(iin: String) async throws -> POCardIssuerInformation

    /// Tokenizes a card. You can use the card for a single payment by creating a card token with it. If you want
    /// to use the card for multiple payments then you can use the card token to create a reusable customer token.
    /// Note that once you have used the card token either for a payment or to create a customer token, the card
    /// token becomes invalid and you cannot use it for any further actions.
    func tokenize(request: POCardTokenizationRequest) async throws -> POCard

    /// Updates card information.
    func updateCard(request: POCardUpdateRequest) async throws -> POCard

    /// Tokenize previously authorized payment.
    func tokenize(request: POApplePayPaymentTokenizationRequest) async throws -> POCard

    /// Authorize given payment request and tokenize it.
    func tokenize(
        request: POApplePayTokenizationRequest, delegate: POApplePayTokenizationDelegate?
    ) async throws -> POCard
}

extension POCardsService {

    /// Authorize given payment request and tokenize it.
    public func tokenize(request: POApplePayTokenizationRequest) async throws -> POCard {
        try await tokenize(request: request, delegate: nil)
    }
}

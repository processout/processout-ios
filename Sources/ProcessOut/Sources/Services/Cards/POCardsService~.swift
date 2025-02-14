//
//  POCardsService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.03.2023.
//

@available(*, deprecated, renamed: "POCardsService")
public typealias POCardsServiceType = POCardsService

/// Provides set of methods to tokenize and manipulate cards.
public protocol POCardsService: POService { // sourcery: AutoCompletion

    /// Allows to retrieve card issuer information based on IIN.
    ///
    /// - Parameters:
    ///   - iin: Card issuer identification number. Length should be at least 6 otherwise error is thrown.
    func issuerInformation(iin: String) async throws(Failure) -> POCardIssuerInformation

    /// Tokenizes a card. You can use the card for a single payment by creating a card token with it. If you want
    /// to use the card for multiple payments then you can use the card token to create a reusable customer token.
    /// Note that once you have used the card token either for a payment or to create a customer token, the card
    /// token becomes invalid and you cannot use it for any further actions.
    func tokenize(request: POCardTokenizationRequest) async throws(Failure) -> POCard

    /// Updates card information.
    func updateCard(request: POCardUpdateRequest) async throws(Failure) -> POCard

    /// Tokenize previously authorized payment.
    @MainActor
    @preconcurrency
    func tokenize(request: POApplePayPaymentTokenizationRequest) async throws(Failure) -> POCard

    /// Authorize given payment request and tokenize it.
    @MainActor
    @preconcurrency
    func tokenize(
        request: POApplePayTokenizationRequest, delegate: POApplePayTokenizationDelegate?
    ) async throws(Failure) -> POCard
}

extension POCardsService {

    /// Authorize given payment request and tokenize it.
    @MainActor
    @preconcurrency
    public func tokenize(request: POApplePayTokenizationRequest) async throws(Failure) -> POCard {
        try await tokenize(request: request, delegate: nil)
    }
}

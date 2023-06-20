//
//  POCardsService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.03.2023.
//

@available(*, deprecated, renamed: "POCardsService")
public typealias POCardsServiceType = POCardsService

/// Provides set of methods to tokenize and manipulate cards.
public protocol POCardsService: POService {

    /// Allows to retrieve card issuer information based on iin.
    func issuerInformation(
        request: POCardIssuerInformationRequest,
        completion: @escaping (Result<POCardIssuerInformation, Failure>) -> Void
    )

    /// Tokenizes a card. You can use the card for a single payment by creating a card token with it. If you want
    /// to use the card for multiple payments then you can use the card token to create a reusable customer token.
    /// Note that once you have used the card token either for a payment or to create a customer token, the card
    /// token becomes invalid and you cannot use it for any further actions.
    func tokenize(request: POCardTokenizationRequest, completion: @escaping (Result<POCard, Failure>) -> Void)

    /// Updates card information.
    func updateCard(request: POCardUpdateRequest, completion: @escaping (Result<POCard, Failure>) -> Void)

    /// Tokenize a card via ApplePay. You can use the card for a single payment by creating a card token with it.
    func tokenize(request: POApplePayCardTokenizationRequest, completion: @escaping (Result<POCard, Failure>) -> Void)
}

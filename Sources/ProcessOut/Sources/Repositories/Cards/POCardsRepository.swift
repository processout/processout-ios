//
//  POCardsRepository.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

import Foundation

protocol POCardsRepository: PORepository {

    /// Allows to retrieve card issuer information based on iin.
    func issuerInformation(
        request: POCardIssuerInformationRequest,
        completion: @escaping (Result<POCardIssuerInformation, Failure>) -> Void
    )

    /// Tokenize a card.
    func tokenize(request: POCardTokenizationRequest, completion: @escaping (Result<POCard, Failure>) -> Void)

    /// Updates card information.
    func updateCard(request: POCardUpdateRequest, completion: @escaping (Result<POCard, Failure>) -> Void)

    /// Tokenize a card via ApplePay.
    func tokenize(request: ApplePayCardTokenizationRequest, completion: @escaping (Result<POCard, Failure>) -> Void)
}

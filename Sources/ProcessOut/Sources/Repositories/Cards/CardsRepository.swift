//
//  CardsRepository.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

protocol CardsRepository: PORepository {

    /// Allows to retrieve card issuer information based on IIN.
    /// 
    /// - Parameters:
    ///   - iin: Card issuer identification number. Corresponds to the first 6 or 8 digits of the main card number.
    func issuerInformation(iin: String) async throws -> POCardIssuerInformation

    /// Tokenize a card.
    func tokenize(request: POCardTokenizationRequest) async throws -> POCard

    /// Updates card information.
    func updateCard(request: POCardUpdateRequest) async throws -> POCard

    /// Tokenize a card via ApplePay.
    func tokenize(request: ApplePayCardTokenizationRequest) async throws -> POCard
}

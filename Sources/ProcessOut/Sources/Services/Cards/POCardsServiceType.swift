//
//  POCardsServiceType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.03.2023.
//

import Foundation

@_spi(PO)
public protocol POCardsServiceType: POServiceType {

    /// Tokenize a card.
    func tokenize(request: POCardTokenizationRequest, completion: @escaping (Result<POCard, Failure>) -> Void)

    /// Updates card information.
    func updateCard(request: POCardUpdateRequest, completion: @escaping (Result<POCard, Failure>) -> Void)

    /// Tokenize a card via ApplePay.
    func tokenize(request: POApplePayCardTokenizationRequest, completion: @escaping (Result<POCard, Failure>) -> Void)
}

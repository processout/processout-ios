//
//  POCardsRepositoryType.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

import Foundation

@_spi(PO)
public protocol POCardsRepositoryType: PORepositoryType {

    /// Tokenize a card.
    func tokenize(request: POCardTokenizationRequest, completion: @escaping (Result<POCard, Failure>) -> Void)

    /// Update CVC.
    func updateCvc(cardId: String, newCvc: String, completion: @escaping (Result<POCard, Failure>) -> Void)

    /// Tokenize a card via ApplePay.
    func tokenize(request: POApplePayCardTokenizationRequest, completion: @escaping (Result<POCard, Failure>) -> Void)
}

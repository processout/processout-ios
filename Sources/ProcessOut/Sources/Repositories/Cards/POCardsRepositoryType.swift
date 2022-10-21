//
//  POCardsRepositoryType.swift
//  
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

import Foundation

public protocol POCardsRepositoryType: PORepositoryType {

    // Tokenize a card
    func tokenize(
        request: POCardTokenizationRequest,
        completion: @escaping (Result<POCardTokenizationResponse, Failure>) -> Void
    )

    // Update CVC
    func updateCvc(
        cardId: String,
        newCvc: String,
        completion: @escaping (Result<POCardTokenizationResponse, Failure>) -> Void
    )
}

//
//  POPassKitPaymentErrorMapper.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.12.2023.
//

// todo(andrii-vysotskyi): remove public access level when POPassKitPaymentAuthorizationController is removed

@_spi(PO)
public protocol POPassKitPaymentErrorMapper: Sendable {

    /// Converts ProcessOut errors into the appropriate Apple Pay error, for use in
    /// `PKPaymentAuthorizationResult`.
    func map(poError: Error) -> [Error]
}

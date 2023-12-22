//
//  PassKitPaymentErrorMapper.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.12.2023.
//

protocol PassKitPaymentErrorMapper {

    /// Converts ProcessOut errors into the appropriate Apple Pay error, for use in
    /// `PKPaymentAuthorizationResult`.
    func map(poError: Error) -> [Error]
}

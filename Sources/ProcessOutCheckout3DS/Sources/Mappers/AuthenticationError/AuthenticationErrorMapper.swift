//
//  AuthenticationErrorMapper.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 06.03.2023.
//

import ProcessOutCore
import Checkout3DS

protocol AuthenticationErrorMapper: Sendable {

    /// Converts given authentication error to ProcessOut error.
    func convert(error: Checkout3DS.AuthenticationError) -> POFailure
}

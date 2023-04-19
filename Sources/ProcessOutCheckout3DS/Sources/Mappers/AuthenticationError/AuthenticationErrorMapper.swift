//
//  AuthenticationErrorMapper.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 06.03.2023.
//

import ProcessOut
import Checkout3DS

protocol AuthenticationErrorMapper {

    /// Converts given authentication error to processout error.
    func convert(error: Checkout3DS.AuthenticationError) -> POFailure
}

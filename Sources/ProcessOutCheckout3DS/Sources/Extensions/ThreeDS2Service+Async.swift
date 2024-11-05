//
//  ThreeDS2Service+Async.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 05.11.2024.
//

import Checkout3DS

extension ThreeDS2Service {

    /// Method to check for warnings of any potential security warnings or of rejected configuration requests.
    var warnings: Set<Checkout3DS.Warning> {
        get async { getWarnings() }
    }
}

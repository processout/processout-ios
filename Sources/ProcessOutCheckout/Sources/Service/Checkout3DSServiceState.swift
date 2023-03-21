//
//  Checkout3DSServiceState.swift
//  ProcessOutCheckout
//
//  Created by Andrii Vysotskyi on 01.03.2023.
//

import Foundation
import Checkout3DS

enum Checkout3DSServiceState {

    struct Context {

        /// Service.
        let service: ThreeDS2Service

        /// Transaction.
        let transaction: Transaction
    }

    /// Idle state.
    case idle

    /// Fingerprinting.
    case fingerprinting(Context)

    /// Fingerprinting is completed and implementation is now ready for 3DS2 challenge.
    case fingerprinted(Context)

    /// Challenge is currently in progress.
    case challenging(Context)
}

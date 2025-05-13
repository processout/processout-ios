//
//  PO3DS2ChallengeResult+Init.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 28.04.2025.
//

import ProcessOut
import ThreeDS_SDK

extension PO3DS2ChallengeResult {

    init(status: ChallengeStatus) throws(POFailure) {
        switch status {
        case .completed(let completionEvent):
            self = .init(transactionStatus: completionEvent.getTransactionStatus())
        case .cancelled:
            throw POFailure(message: "Challenge was cancelled.", code: .Customer.cancelled)
        case .timedOut:
            throw POFailure(message: "Challenge timed out.", code: .Mobile.timeout)
        case .protocolError(let error):
            throw POFailure(
                message: "Challenge did fail with protocol error.", code: .Mobile.generic, underlyingError: error
            )
        case .runtimeError(let error):
            throw POFailure(
                message: "Challenge did fail with runtime error.", code: .Mobile.generic, underlyingError: error
            )
        }
    }
}

// Adds error conformance retroactively.
extension ProtocolErrorEvent: @retroactive Error { }

// Adds error conformance retroactively.
extension RuntimeErrorEvent: @retroactive Error { }

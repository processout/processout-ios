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
        case .protocolError:
            throw POFailure(code: .Mobile.generic)
        case .runtimeError:
            throw POFailure(code: .Mobile.generic)
        }
    }
}

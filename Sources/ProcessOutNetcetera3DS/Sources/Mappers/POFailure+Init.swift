//
//  POFailure+Init.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.10.2026.
//

import ProcessOut

extension POFailure {

    /// Creates failure with given error. Error is returned as is if it is already a failure,
    /// otherwise it is wrapped into a generic failure with given message.
    init(wrapping error: Error, message: @autoclosure () -> String) {
        if let failure = error as? POFailure {
            self = failure
        } else {
            self.init(message: message(), code: .Mobile.generic, underlyingError: error)
        }
    }
}

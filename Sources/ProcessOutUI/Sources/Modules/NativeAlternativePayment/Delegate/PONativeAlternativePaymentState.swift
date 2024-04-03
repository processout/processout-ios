//
//  PONativeAlternativePaymentState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.03.2024.
//

import ProcessOut

public enum PONativeAlternativePaymentState {

    public struct Started {

        /// Indicates whether form in its current state could be submitted.
        public let isSubmittable: Bool

        /// Boolean value indicating whether cancel is supported in the current state.
        public let isCancellable: Bool
    }

    public struct Submitting {

        /// Boolean value indicating whether cancel is supported in the current state.
        public let isCancellable: Bool
    }

    /// Initial interactor state.
    case idle

    /// Payment is being loaded.
    case starting

    /// Payment has started.
    case started(Started)

    /// Parameter values are being submitted.
    case submitting(Submitting)

    /// Payment is completed.
    case completed(result: Result<Void, POFailure>)
}

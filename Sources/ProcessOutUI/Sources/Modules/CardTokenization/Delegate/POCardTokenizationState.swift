//
//  POCardTokenizationState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 25.03.2024.
//

import ProcessOut

@_spi(PO)
public enum POCardTokenizationState {

    public struct Started {

        /// Defines whether form could be submitted at this moment.
        public let isSubmittable: Bool

        /// Boolean value defining whether cancellation is supported.
        public let isCancellable: Bool
    }

    case idle

    /// Interactor has started and is ready.
    case started(Started)

    /// Card information is currently being tokenized.
    case tokenizing(snapshot: Started)

    /// Card was successfully tokenized. This is a sink state.
    case tokenized

    /// Card tokenization did end with unrecoverable failure. This is a sink state.
    case failure(POFailure)
}

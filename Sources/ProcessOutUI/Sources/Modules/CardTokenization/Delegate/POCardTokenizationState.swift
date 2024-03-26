//
//  POCardTokenizationState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 25.03.2024.
//

import ProcessOut

@_spi(PO)
public enum POCardTokenizationState {

    case idle

    /// Interactor has started and is ready.
    case started(isSubmittable: Bool)

    /// Card information is currently being tokenized.
    case tokenizing

    /// Card was successfully tokenized. This is a sink state.
    case tokenized

    /// Card tokenization did end with unrecoverable failure. This is a sink state.
    case failure(POFailure)
}

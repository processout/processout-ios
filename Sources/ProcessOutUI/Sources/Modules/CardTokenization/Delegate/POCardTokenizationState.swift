//
//  POCardTokenizationState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 25.03.2024.
//

import ProcessOut

public enum POCardTokenizationState {

    case idle

    /// Interactor has started and is ready.
    case started(isSubmittable: Bool)

    /// Card information is currently being tokenized.
    case tokenizing

    /// Card tokenization is completed.
    case completed(result: Result<POCard, POFailure>)
}
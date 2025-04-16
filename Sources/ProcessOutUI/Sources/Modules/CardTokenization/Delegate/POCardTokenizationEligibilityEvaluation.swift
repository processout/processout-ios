//
//  POCardTokenizationEligibilityEvaluation.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.04.2025.
//

import ProcessOut

public struct POCardTokenizationEligibilityEvaluation: Sendable {

    enum Eligibility {
        case notEligible(POFailure), eligible(schemes: Set<POCardScheme>?)
    }

    let eligibility: Eligibility
}

extension POCardTokenizationEligibilityEvaluation {

    public static func notEligible(failure: POFailure) -> Self {
        .init(eligibility: .notEligible(failure))
    }

    public static func eligible(schemes: Set<POCardScheme>? = nil) -> Self {
        .init(eligibility: .eligible(schemes: schemes))
    }
}

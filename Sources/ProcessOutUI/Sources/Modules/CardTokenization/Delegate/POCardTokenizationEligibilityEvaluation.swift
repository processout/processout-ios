//
//  POCardTokenizationEligibilityEvaluation.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.04.2025.
//

import ProcessOut

/// Represents the eligibility evaluation of a card for tokenization.
public struct POCardTokenizationEligibilityEvaluation: Sendable {

    enum RawValue: Sendable {
        case notEligible(POFailure?), eligible(scheme: POCardScheme?)
    }

    let rawValue: RawValue
}

extension POCardTokenizationEligibilityEvaluation {

    /// Returns an instance indicating that the card is not eligible, with optional failure details.
    ///
    /// You may provide a ``POFailure`` containing a localized `errorDescription` that will be shown directly to the user.
    public static func notEligible(failure: POFailure? = nil) -> Self {
        .init(rawValue: .notEligible(failure))
    }

    /// Returns an instance indicating that the card is eligible, optionally restricted to a specific card scheme.
    public static func eligible(scheme: POCardScheme? = nil) -> Self {
        .init(rawValue: .eligible(scheme: scheme))
    }
}

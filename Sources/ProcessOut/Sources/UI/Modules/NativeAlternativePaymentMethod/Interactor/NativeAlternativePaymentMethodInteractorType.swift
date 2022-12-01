//
//  NativeAlternativePaymentMethodInteractorType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2022.
//

import Foundation

protocol NativeAlternativePaymentMethodInteractorType: InteractorType
    where State == NativeAlternativePaymentMethodInteractorState {

    /// Updates value for given key.
    /// - Returns: `true` if value was updated, `false` otherwise.
    @discardableResult
    func updateValue(_ value: String?, for key: String) -> Bool

    /// Submits parameters.
    func submit()
}

enum NativeAlternativePaymentMethodInteractorState {

    struct ParameterValue {

        /// Actual parameter value.
        let value: String?

        /// Boolean value indicating if parameter value is valid.
        let isValid: Bool
    }

    struct Started {

        /// Message with details about what's expected from user.
        let message: String?

        /// Parameters that expected from user.
        let parameters: [PONativeAlternativePaymentMethodParameter]

        /// Parameter values.
        let values: [String: ParameterValue]

        /// Boolean value indicating whether submit it currently allowed.
        let isSubmitAllowed: Bool
    }

    /// Initial interactor state.
    case idle

    /// Interactor is loading initial content portion.
    case starting

    /// Interactor is started and awaits for parameters values.
    case started(Started)

    /// Parameter values are being submitted.
    case submitting(snapshot: Started)

    /// Submit operation did fail.
    case submissionFailure(snapshot: Started, failure: POFailure)

    /// Parameters were submitted and accepted. This is a sink state.
    case submitted(snapshot: Started)

    /// Starting failure.
    case failure
}

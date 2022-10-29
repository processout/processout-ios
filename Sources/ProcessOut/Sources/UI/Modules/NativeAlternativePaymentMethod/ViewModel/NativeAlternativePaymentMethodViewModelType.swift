//
//  NativeAlternativePaymentMethodViewModelType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2022.
//

import Foundation

protocol NativeAlternativePaymentMethodViewModelType: ViewModelType
    where State == NativeAlternativePaymentMethodViewModelState {

    /// Submits parameter values.
    func submit()
}

enum NativeAlternativePaymentMethodViewModelState {

    typealias ParameterType = PONativeAlternativePaymentMethodParameter.ParameterType

    struct Parameter {

        /// Parameter identifier.
        let id: String

        /// Parameter's placeholder.
        let placeholder: String

        /// Current parameter's value.
        let value: String

        /// Indicates if parameter is required.
        let isRequired: Bool

        /// Parameter type.
        let type: ParameterType

        /// Updates parameter value.
        let update: (_ value: String) -> Bool
    }

    struct Started {

        /// Current message.
        let message: String?

        /// Available parameters.
        let parameters: [Parameter]

        /// Boolean value indicating whether data can be submitted.
        let isSubmitAllowed: Bool

        /// Boolean value indicating if data is being submitted.
        let isSubmitting: Bool
    }

    case idle, starting, started(Started), failure
}

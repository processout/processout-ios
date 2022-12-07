//
//  NativeAlternativePaymentMethodViewModelType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2022.
//

import Foundation
import class UIKit.UIImage

protocol NativeAlternativePaymentMethodViewModelType: ViewModelType
    where State == NativeAlternativePaymentMethodViewModelState {

    /// Submits parameter values.
    func submit()
}

enum NativeAlternativePaymentMethodViewModelState {

    typealias ParameterType = PONativeAlternativePaymentMethodParameter.ParameterType

    struct Action {

        /// Action title.
        let title: String

        /// Boolean value indicating whether action is enabled.
        let isEnabled: Bool

        /// Action handler.
        let handler: () -> Void
    }

    struct Parameter {

        /// Parameter's name.
        let name: String

        /// Parameter's placeholder.
        let placeholder: String?

        /// Current parameter's value.
        let value: String

        /// Parameter type.
        let type: ParameterType

        /// Required parameter's length.
        let length: Int?

        /// Error message associated with this parameter if any.
        let errorMessage: String?

        /// Updates parameter value.
        let update: (_ value: String) -> Void
    }

    struct Started {

        /// Title.
        let title: String

        /// Available parameters.
        let parameters: [Parameter]

        /// The most recent failure message if any.
        let failureMessage: String?

        /// Boolean value indicating if data is being submitted.
        let isSubmitting: Bool

        /// Action information.
        let action: Action
    }

    struct Success {

        /// Gateway's logo image.
        let gatewayLogo: UIImage?

        /// Success message.
        let message: String
    }

    struct PendingAction {

        /// Gateway's logo image.
        let gatewayLogo: UIImage?

        /// Success message.
        let message: String

        /// Image illustrating action.
        let image: UIImage?
    }

    case idle, loading, started(Started), pendingAction(PendingAction), success(Success)
}

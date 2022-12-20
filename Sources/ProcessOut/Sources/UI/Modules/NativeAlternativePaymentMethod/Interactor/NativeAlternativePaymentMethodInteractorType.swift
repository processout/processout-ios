//
//  NativeAlternativePaymentMethodInteractorType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2022.
//

import Foundation
import class UIKit.UIImage

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

        /// The most recent error message associated with this parameter value.
        let recentErrorMessage: String?
    }

    struct Started {

        /// Name of the payment gateway that can be displayed.
        let gatewayDisplayName: String

        /// Gateway's logo URL.
        let gatewayLogo: UIImage?

        /// Customer action image URL if any.
        let customerActionImageUrl: URL?

        /// Invoice amount.
        let amount: Decimal

        /// Invoice currency code.
        let currencyCode: String

        /// Parameters that are expected from user.
        let parameters: [PONativeAlternativePaymentMethodParameter]

        /// Parameter values.
        let values: [String: ParameterValue]

        /// The most recent error message.
        let recentFailure: POFailure?

        /// Boolean value indicating whether submit it currently allowed.
        let isSubmitAllowed: Bool
    }

    struct AwaitingCapture {

        /// Gateway logo.
        let gatewayLogoImage: UIImage?

        /// Messaged describing additional actions that are needed from user in order to capture payment.
        let expectedActionMessage: String?

        /// Action image.
        let actionImage: UIImage?
    }

    struct Captured {

        /// Gateway logo.
        let gatewayLogo: UIImage?
    }

    /// Initial interactor state.
    case idle

    /// Interactor is loading initial content portion.
    case starting

    /// Interactor is started and awaits for parameters values.
    case started(Started)

    /// Starting failure.
    case failure(POFailure)

    /// Parameter values are being submitted.
    case submitting(snapshot: Started)

    /// Interactor did fail to submit values and encountered unrecoverable error. This is a sink state.
    case submissionFailure(POFailure)

    /// Parameter values were submitted.
    /// - NOTE: This is a sink state and it's only set if user opted out from awaiting capture.
    case submitted

    /// Parameters were submitted and accepted. This is a sink state.
    case awaitingCapture(AwaitingCapture)

    /// Payment is completed.
    case captured(Captured)

    /// Implementation did fail to capture payment. This is a sink state.
    case captureFailure(POFailure)
}

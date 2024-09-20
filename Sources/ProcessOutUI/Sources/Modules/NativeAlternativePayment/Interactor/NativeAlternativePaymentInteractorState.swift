//
//  NativeAlternativePaymentInteractorState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.02.2024.
//

import Foundation
import Combine
import UIKit
import ProcessOut

enum NativeAlternativePaymentInteractorState {

    struct Started {

        /// Name of the payment gateway that can be displayed.
        let gateway: PONativeAlternativePaymentMethodTransactionDetails.Gateway

        /// Invoice details.
        let invoice: PONativeAlternativePaymentMethodTransactionDetails.Invoice

        /// Parameters that are expected from user.
        var parameters: [Parameter]

        /// Boolean value indicating whether "soft" cancelation is supported in the current state.
        var isCancellable: Bool
    }

    struct AwaitingCapture {

        /// Payment provider details.
        let paymentProvider: PaymentProvider

        /// Additional action details.
        let customerAction: CaptureCustomerAction?

        /// Boolean value indicating whether "soft" cancelation is supported in the current state.
        var isCancellable: Bool

        /// Capture cancellable.
        /// - NOTE: For internal use by interactor only.
        var cancellable: AnyCancellable?

        /// Boolean value indicating whether capture takes longer than anticipated.
        var isDelayed: Bool

        /// Boolean value indicating whether payment should be manually confirmed by user to start capture.
        var shouldConfirmCapture: Bool
    }

    struct Captured {

        /// Payment provider details.
        let paymentProvider: PaymentProvider
    }

    struct Parameter {

        /// Parameter specification that includes but not limited to its type, length, name etc.
        let specification: PONativeAlternativePaymentMethodParameter

        /// Formatter that could be used to format parameter.
        let formatter: Formatter?

        /// Actual parameter value.
        var value: String?

        /// The most recent error message associated with this parameter value.
        var recentErrorMessage: String?
    }

    struct PaymentProvider {

        /// Payment provider name.
        let name: String?

        /// Payment provider or gateway logo image.
        let image: UIImage?
    }

    struct CaptureCustomerAction {

        /// Messaged describing additional actions that are needed from user in order to capture payment.
        let message: String

        /// Action image.
        let image: UIImage?
    }

    /// Initial interactor state.
    case idle

    /// Interactor is loading initial content portion.
    case starting

    /// Interactor is started and awaits for parameters values.
    case started(Started)

    /// Starting failure. This is a sink state.
    case failure(POFailure)

    /// Parameter values are being submitted.
    case submitting(snapshot: Started)

    /// Parameter values were submitted.
    /// - NOTE: This is a sink state and it's only set if user opted out from awaiting capture.
    case submitted

    /// Parameters were submitted and accepted.
    case awaitingCapture(AwaitingCapture)

    /// Payment is completed.
    case captured(Captured)
}

extension NativeAlternativePaymentInteractorState.Started {

    /// Boolean value that allows to determine whether all parameters are valid.
    var areParametersValid: Bool {
        parameters.allSatisfy { $0.recentErrorMessage == nil }
    }
}

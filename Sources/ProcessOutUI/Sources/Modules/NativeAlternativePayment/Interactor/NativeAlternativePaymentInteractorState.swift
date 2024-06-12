//
//  NativeAlternativePaymentInteractorState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.02.2024.
//

import Foundation
import SwiftUI
import ProcessOut

enum NativeAlternativePaymentInteractorState {

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

    struct Started {

        /// Name of the payment gateway that can be displayed.
        let gateway: PONativeAlternativePaymentMethodTransactionDetails.Gateway

        /// Invoice amount.
        let amount: Decimal

        /// Invoice currency code.
        let currencyCode: String

        /// Parameters that are expected from user.
        var parameters: [Parameter]

        /// Boolean value indicating whether cancel is supported in the current state.
        var isCancellable: Bool
    }

    struct AwaitingCapture {

        /// Payment provider name.
        let paymentProviderName: String?

        /// Payment provider or gateway logo image.
        let logoImage: UIImage?

        /// Messaged describing additional actions that are needed from user in order to capture payment.
        let actionMessage: String?

        /// Action image.
        let actionImage: UIImage?

        /// Boolean value indicating whether cancel is supported in the current state.
        var isCancellable: Bool

        /// Boolean value indicating whether capture takes longer than anticipated.
        var isDelayed: Bool
    }

    struct Captured {

        /// Payment provider name.
        let paymentProviderName: String?

        /// Payment provider or gateway logo image.
        let logoImage: UIImage?
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

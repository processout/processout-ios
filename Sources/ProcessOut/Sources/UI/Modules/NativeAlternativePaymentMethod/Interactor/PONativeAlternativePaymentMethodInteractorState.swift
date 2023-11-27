//
//  PONativeAlternativePaymentMethodInteractorState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import UIKit

@_spi(PO) public enum PONativeAlternativePaymentMethodInteractorState {

    public struct ParameterValue {

        /// Actual parameter value.
        public let value: String?

        /// The most recent error message associated with this parameter value.
        public let recentErrorMessage: String?
    }

    public struct Started {

        /// Name of the payment gateway that can be displayed.
        public let gateway: PONativeAlternativePaymentMethodTransactionDetails.Gateway

        /// Invoice amount.
        public let amount: Decimal

        /// Invoice currency code.
        public let currencyCode: String

        /// Parameters that are expected from user.
        public let parameters: [PONativeAlternativePaymentMethodParameter]

        /// Parameter values.
        public let values: [String: ParameterValue]

        /// Boolean value indicating whether submit it currently allowed.
        public let isSubmitAllowed: Bool
    }

    public struct AwaitingCapture {

        /// Payment provider name.
        public let paymentProviderName: String?

        /// Payment provider or gateway logo image.
        public let logoImage: UIImage?

        /// Messaged describing additional actions that are needed from user in order to capture payment.
        public let actionMessage: String?

        /// Action image.
        public let actionImage: UIImage?
    }

    public struct Captured {

        /// Payment provider name.
        public let paymentProviderName: String?

        /// Payment provider or gateway logo image.
        public let logoImage: UIImage?
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

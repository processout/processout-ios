//
//  PODynamicCheckoutAlternativePaymentConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import Foundation

/// Alternative payment specific dynamic checkout configuration.
public struct PODynamicCheckoutAlternativePaymentConfiguration {

    public struct PaymentConfirmation {

        /// Amount of time (in seconds) that module is allowed to wait before receiving final payment confirmation.
        /// Default timeout is 3 minutes while maximum value is 15 minutes.
        public let timeout: TimeInterval

        /// A delay before showing progress indicator during payment confirmation.
        public let showProgressIndicatorAfter: TimeInterval?

        /// Action that could be optionally presented to user during payment confirmation stage. To remove action
        /// use `nil`, this is default behaviour.
        public let cancelButton: CancelButton?

        /// Creates confirmation configuration.
        public init(
            timeout: TimeInterval = 180,
            showProgressIndicatorAfter: TimeInterval? = nil,
            cancelButton: CancelButton? = nil
        ) {
            self.timeout = timeout
            self.showProgressIndicatorAfter = showProgressIndicatorAfter
            self.cancelButton = cancelButton
        }
    }

    public struct CancelButton {

        /// Cancel button title. Use `nil` for default title.
        public let title: String?

        /// By default user can interact with action immediately after it becomes visible, it is
        /// possible to make it initially disabled for given amount of time.
        public let disabledFor: TimeInterval

        /// When property is set implementation asks user to confirm cancel.
        public let confirmation: POConfirmationDialogConfiguration?

        public init(
            title: String? = nil,
            disabledFor: TimeInterval,
            confirmation: POConfirmationDialogConfiguration? = nil
        ) {
            self.title = title
            self.disabledFor = disabledFor
            self.confirmation = confirmation
        }
    }

    /// Return URL to expect when handling OOB or web based payments.
    public let returnUrl: URL?

    /// For parameters where user should select single option from multiple values defines
    /// maximum number of options that framework will display inline (e.g. using radio buttons).
    ///
    /// Default value is `5`.
    public let inlineSingleSelectValuesLimit: Int

    /// Payment confirmation configuration for payment method where available.
    public let paymentConfirmation: PaymentConfirmation

    /// Creates configuration.
    public init(
        returnUrl: URL? = nil,
        inlineSingleSelectValuesLimit: Int = 5,
        paymentConfirmation: PaymentConfirmation = .init()
    ) {
        self.returnUrl = returnUrl
        self.inlineSingleSelectValuesLimit = inlineSingleSelectValuesLimit
        self.paymentConfirmation = paymentConfirmation
    }
}

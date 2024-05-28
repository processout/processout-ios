//
//  PODynamicCheckoutAlternativePaymentConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import Foundation

public struct PODynamicCheckoutAlternativePaymentConfiguration {

    public struct CancelAction {

        /// Action title. Pass `nil` title to use default value.
        public var title: String?

        /// By default user can interact with action immediately after it becomes visible, it is
        /// possible to make it initially disabled for given amount of time.
        public var disabledFor: TimeInterval = 0
    }

    public struct Confirmation {

        /// Amount of time (in seconds) that module is allowed to wait before receiving final payment confirmation.
        /// Maximum value is 180 seconds.
        public var timeout: TimeInterval = 180

        /// A delay before showing progress indicator during payment confirmation.
        public var showProgressIndicatorAfter: TimeInterval?

        /// Action that could be optionally presented to user during payment confirmation stage. To remove action
        /// use `nil`, this is default behaviour.
        public var cancelAction: CancelAction?
    }

    /// Return URL to expect when handling OOB or web based payments.
    public var returnUrl: URL?

    /// Custom title.
    public var title: String?

    /// Primary action text, such as "Pay".
    public var primaryActionTitle: String?

    /// Cancel action title. Use empty string to hide button.
    public var cancelActionTitle: String?

    /// For parameters where user should select single option from multiple values defines
    /// maximum number of options that framework will display inline (e.g. using radio buttons).
    ///
    /// Default value is `5`.
    public var inlineSingleSelectValuesLimit: Int = 5

    /// Payment confirmation configuration.
    public var paymentConfirmation = Confirmation()
}

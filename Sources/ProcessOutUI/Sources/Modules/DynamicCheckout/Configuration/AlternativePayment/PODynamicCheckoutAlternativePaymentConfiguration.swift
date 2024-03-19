//
//  PODynamicCheckoutAlternativePaymentConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import Foundation

public struct PODynamicCheckoutAlternativePaymentConfiguration {

    /// Return URL to expect when handling OOB or web based payments.
    public var returnUrl: URL?

    /// Custom title.
    public var title: String?

    /// Custom success message to display user when payment completes.
    public var successMessage: String?

    /// Primary action text, such as "Pay".
    public var primaryActionTitle: String?

    /// Cancel action title. Use empty string to hide button.
    public var cancelActionTitle: String?

    /// For parameters where user should select single option from multiple values defines
    /// maximum number of options that framework will display inline (e.g. using radio buttons).
    ///
    /// Default value is `5`.
    public var inlineSingleSelectValuesLimit: Int = 5

    /// Boolean value that indicates whether capture success screen should be skipped. Default value is `false`.
    public var skipSuccessScreen = false

    /// Payment confirmation configuration.
    public var paymentConfirmation = PODynamicCheckoutAlternativePaymentConfirmationConfiguration()
}

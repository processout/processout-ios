//
//  PONativeAlternativePaymentConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import Foundation
import ProcessOut

/// A configuration object that defines how a native alternative payment view content.
/// Use `nil` to indicate that default value should be used.
public struct PONativeAlternativePaymentConfiguration {

    public enum SecondaryAction {

        /// Cancel action.
        ///
        /// - Parameters:
        ///   - title: Action title. Pass `nil` title to use default value.
        ///   - disabledFor: By default user can interact with action immediately after it becomes visible, it is
        ///   possible to make it initially disabled for given amount of time.
        ///   - confirmation: When property is set implementation asks user to confirm cancel.
        case cancel(
            title: String? = nil, disabledFor: TimeInterval = 0, confirmation: POConfirmationDialogConfiguration? = nil
        )
    }

    /// Invoice that should be authorized/captured.
    public let invoiceId: String

    /// Gateway configuration id that should be used to initiate native alternative payment.
    public let gatewayConfigurationId: String

    /// Custom title.
    public let title: String?

    /// A Boolean property that indicates whether the code input should be horizontally centered. This property
    /// is only applicable when there is a single code input. If there are multiple inputs the alignment is always
    /// leading. Default value is `true`.
    public let shouldHorizontallyCenterCodeInput: Bool

    /// Custom success message **markdown** to display user when payment completes.
    public let successMessage: String?

    /// Primary action text, such as "Pay".
    public let primaryActionTitle: String?

    /// Secondary action. To remove secondary action use `nil`, this is default behaviour.
    public let secondaryAction: SecondaryAction?

    /// For parameters where user should select single option from multiple values defines
    /// maximum number of options that framework will display inline (e.g. using radio buttons).
    ///
    /// Default value is `5`.
    public let inlineSingleSelectValuesLimit: Int

    /// Boolean value that indicates whether capture success screen should be skipped. Default value is `false`.
    public let skipSuccessScreen: Bool

    /// Payment confirmation configuration.
    public let paymentConfirmation: PONativeAlternativePaymentConfirmationConfiguration

    /// Creates configuration instance.
    public init(
        invoiceId: String,
        gatewayConfigurationId: String,
        title: String? = nil,
        shouldHorizontallyCenterCodeInput: Bool = true,
        successMessage: String? = nil,
        primaryActionTitle: String? = nil,
        secondaryAction: SecondaryAction? = nil,
        inlineSingleSelectValuesLimit: Int = 5,
        skipSuccessScreen: Bool = false,
        paymentConfirmation: PONativeAlternativePaymentConfirmationConfiguration = .init()
    ) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.title = title
        self.shouldHorizontallyCenterCodeInput = shouldHorizontallyCenterCodeInput
        self.successMessage = successMessage
        self.primaryActionTitle = primaryActionTitle
        self.secondaryAction = secondaryAction
        self.inlineSingleSelectValuesLimit = inlineSingleSelectValuesLimit
        self.skipSuccessScreen = skipSuccessScreen
        self.paymentConfirmation = paymentConfirmation
    }
}

//
//  PONativeAlternativePaymentConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import Foundation
import SwiftUI
import ProcessOut

/// A configuration object that defines how a native alternative payment view content.
/// Use `nil` to indicate that default value should be used.
public struct PONativeAlternativePaymentConfiguration {

    /// Payment confirmation configuration.
    public struct Confirmation {

        /// Boolean value that specifies whether module should wait for payment confirmation from PSP or will
        /// complete right after all user's input is submitted. Default value is `true`.
        public let waitsConfirmation: Bool

        /// Amount of time (in seconds) that module is allowed to wait before receiving final payment confirmation.
        /// Default timeout is 3 minutes while maximum value is 15 minutes.
        public let timeout: TimeInterval

        /// A delay before showing progress indicator during payment confirmation.
        public let showProgressIndicatorAfter: TimeInterval?

        /// Boolean value indicating whether gateway information (such as name/logo) should stay hidden
        /// during payment confirmation even if more specific payment provider details are not available.
        /// Default value is `false`.
        public let hideGatewayDetails: Bool

        /// Payment confirmation button configuration. To remove button use `nil`, this is default behaviour.
        ///
        /// Displays a confirmation button when the user needs to perform an external customer action (e.g.,
        /// completing a step with a third-party service) before proceeding with payment capture. The user
        /// must press this button to continue.
        public let confirmButton: Button?

        /// Cancel button that could be optionally presented to user during payment confirmation stage. To
        /// remove action use `nil`, this is default behaviour.
        public let cancelButton: CancelButton?

        public init(
            waitsConfirmation: Bool = true,
            timeout: TimeInterval = 180,
            showProgressIndicatorAfter: TimeInterval? = nil,
            hideGatewayDetails: Bool = false,
            confirmButton: Button? = nil,
            cancelButton: CancelButton? = nil
        ) {
            self.waitsConfirmation = waitsConfirmation
            self.timeout = timeout
            self.showProgressIndicatorAfter = showProgressIndicatorAfter
            self.hideGatewayDetails = hideGatewayDetails
            self.confirmButton = confirmButton
            self.cancelButton = cancelButton
        }
    }

    /// Payment success configuration.
    public struct Success: Sendable {

        /// Custom success message to display user when payment completes.
        public let message: String?

        /// Defines for how long implementation delays calling completion in case of success.
        /// Default duration is 3 seconds.
        public let duration: TimeInterval

        /// Creates configuration instance.
        public init(message: String? = nil, duration: TimeInterval = 3) {
            self.message = message
            self.duration = duration
        }
    }

    /// Configuration options for barcode interaction.
    @_spi(PO)
    public struct BarcodeInteraction {

        /// Button title.
        public let saveButton: Button

        /// Save error confirmation dialog.
        public let saveErrorConfirmation: POConfirmationDialogConfiguration?

        /// Indicates if haptic feedback is generated during barcode interaction. Feedback is only provided
        /// when the barcode is successfully saved. Default is true.
        public let generateHapticFeedback: Bool

        public init(
            saveButton: Button = .init(),
            saveErrorConfirmation: POConfirmationDialogConfiguration? = nil,
            generateHapticFeedback: Bool = true
        ) {
            self.saveButton = saveButton
            self.saveErrorConfirmation = saveErrorConfirmation
            self.generateHapticFeedback = generateHapticFeedback
        }
    }

    /// Button configuration.
    public struct Button {

        /// Button title, such as "Pay". Pass `nil` title to use default value.
        public let title: String?

        /// Button icon. Pass `nil` to remove icon.
        public let icon: Image?

        public init(title: String? = nil, icon: Image? = nil) {
            self.title = title
            self.icon = icon
        }
    }

    /// Cancel button configuration.
    public struct CancelButton {

        /// Button title. Pass `nil` title to use default value.
        public let title: String?

        /// Button icon. Pass `nil` to remove icon.
        public let icon: Image?

        /// By default user can interact with button immediately after it becomes visible, it is
        /// possible to make it initially disabled for given amount of time.
        public let disabledFor: TimeInterval

        /// When property is set implementation asks user to confirm cancel.
        public let confirmation: POConfirmationDialogConfiguration?

        /// Creates cancel button configuration.
        public init(
            title: String? = nil,
            icon: Image? = nil,
            disabledFor: TimeInterval = 0,
            confirmation: POConfirmationDialogConfiguration? = nil
        ) {
            self.title = title
            self.icon = icon
            self.disabledFor = disabledFor
            self.confirmation = confirmation
        }
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

    /// For parameters where user should select single option from multiple values defines
    /// maximum number of options that framework will display inline (e.g. using radio buttons).
    ///
    /// Default value is `5`.
    public let inlineSingleSelectValuesLimit: Int

    /// Submit button configuration.
    public let submitButton: Button

    /// Cancel button configuration.
    public let cancelButton: CancelButton?

    /// Payment confirmation configuration.
    public let paymentConfirmation: Confirmation

    /// Payment success screen configuration. In order to avoid showing success screen to user pass `nil`.
    public let success: Success?

    /// Barcode interaction configuration.
    @_spi(PO)
    public var barcodeInteraction: BarcodeInteraction?

    /// Creates configuration.
    public init(
        invoiceId: String,
        gatewayConfigurationId: String,
        title: String? = nil,
        shouldHorizontallyCenterCodeInput: Bool = true,
        inlineSingleSelectValuesLimit: Int = 5,
        submitButton: Button = .init(),
        cancelButton: CancelButton? = nil,
        paymentConfirmation: Confirmation = .init(),
        success: Success? = .init()
    ) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.title = title
        self.shouldHorizontallyCenterCodeInput = shouldHorizontallyCenterCodeInput
        self.inlineSingleSelectValuesLimit = inlineSingleSelectValuesLimit
        self.submitButton = submitButton
        self.cancelButton = cancelButton
        self.paymentConfirmation = paymentConfirmation
        self.success = success
    }
}

// MARK: - Deprecated Symbols

extension PONativeAlternativePaymentConfiguration {

    @available(*, deprecated, message: "Use CancelButton instead.")
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

    /// Primary action text, such as "Pay".
    @available(*, deprecated, renamed: "submitButton.title")
    public var primaryActionTitle: String? {
        submitButton.title
    }

    /// Secondary action. To remove secondary action use `nil`, this is default behaviour.
    @available(*, deprecated)
    public var secondaryAction: SecondaryAction? {
        cancelButton.map { .cancel(title: $0.title, disabledFor: $0.disabledFor, confirmation: $0.confirmation) }
    }

    /// Boolean value that specifies whether module should wait for payment confirmation from PSP or will
    /// complete right after all user's input is submitted. Default value is `true`.
    @available(*, deprecated, renamed: "paymentConfirmation.waitsConfirmation")
    public var waitsPaymentConfirmation: Bool {
        paymentConfirmation.waitsConfirmation
    }

    /// Amount of time (in seconds) that module is allowed to wait before receiving final payment confirmation.
    /// Default timeout is 3 minutes while maximum value is 15 minutes.
    @available(*, deprecated, renamed: "paymentConfirmation.timeout")
    public var paymentConfirmationTimeout: TimeInterval {
        paymentConfirmation.timeout
    }

    /// Action that could be optionally presented to user during payment confirmation stage. To remove action
    /// use `nil`, this is default behaviour.
    @available(*, deprecated, renamed: "paymentConfirmation.secondaryAction")
    public var paymentConfirmationSecondaryAction: SecondaryAction? {
        paymentConfirmation.secondaryAction
    }

    /// Boolean value that indicates whether capture success screen should be skipped. Default value is `false`.
    @available(*, deprecated)
    public var skipSuccessScreen: Bool {
        success == nil
    }

    /// Custom success message **markdown** to display user when payment completes.
    @available(*, deprecated, renamed: "success.message")
    public var successMessage: String? {
        success?.message
    }

    /// Creates configuration instance.
    @available(*, deprecated)
    @_disfavoredOverload
    public init(
        invoiceId: String,
        gatewayConfigurationId: String,
        title: String? = nil,
        successMessage: String? = nil,
        primaryActionTitle: String? = nil,
        secondaryAction: SecondaryAction? = nil,
        inlineSingleSelectValuesLimit: Int = 5,
        skipSuccessScreen: Bool = false,
        waitsPaymentConfirmation: Bool = true,
        paymentConfirmationTimeout: TimeInterval = 180,
        paymentConfirmationSecondaryAction: SecondaryAction? = nil
    ) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.title = title
        self.shouldHorizontallyCenterCodeInput = true
        self.success = skipSuccessScreen ? nil : .init(message: successMessage)
        self.submitButton = .init(title: primaryActionTitle)
        self.cancelButton = secondaryAction.flatMap { .init(bridging: $0) }
        self.inlineSingleSelectValuesLimit = inlineSingleSelectValuesLimit
        self.paymentConfirmation = .init(
            waitsConfirmation: waitsPaymentConfirmation,
            timeout: paymentConfirmationTimeout,
            secondaryAction: paymentConfirmationSecondaryAction
        )
    }

    /// Creates configuration instance.
    @available(*, deprecated)
    @_disfavoredOverload
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
        paymentConfirmation: Confirmation = .init()
    ) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.title = title
        self.shouldHorizontallyCenterCodeInput = shouldHorizontallyCenterCodeInput
        self.success = skipSuccessScreen ? nil : .init(message: successMessage)
        self.submitButton = .init(title: primaryActionTitle)
        self.cancelButton = secondaryAction.flatMap { .init(bridging: $0) }
        self.inlineSingleSelectValuesLimit = inlineSingleSelectValuesLimit
        self.paymentConfirmation = paymentConfirmation
    }
}

extension PONativeAlternativePaymentConfiguration.Confirmation {

    @available(*, deprecated)
    public typealias ConfirmButton = PONativeAlternativePaymentConfiguration.Button

    /// Action that could be optionally presented to user during payment confirmation stage. To remove action
    /// use `nil`, this is default behaviour.
    @available(*, deprecated)
    public var secondaryAction: PONativeAlternativePaymentConfiguration.SecondaryAction? {
        cancelButton.map { .cancel(title: $0.title, disabledFor: $0.disabledFor, confirmation: $0.confirmation) }
    }

    /// Creates configuration instance.
    @available(*, deprecated)
    @_disfavoredOverload
    public init(
        waitsConfirmation: Bool = true,
        timeout: TimeInterval = 180,
        showProgressIndicatorAfter: TimeInterval? = nil,
        hideGatewayDetails: Bool = false,
        confirmButton: ConfirmButton? = nil,
        secondaryAction: PONativeAlternativePaymentConfiguration.SecondaryAction? = nil
    ) {
        self.waitsConfirmation = waitsConfirmation
        self.timeout = timeout
        self.showProgressIndicatorAfter = showProgressIndicatorAfter
        self.hideGatewayDetails = hideGatewayDetails
        self.confirmButton = confirmButton
        self.cancelButton = secondaryAction.flatMap { .init(bridging: $0) }
    }
}

extension PONativeAlternativePaymentConfiguration.CancelButton {

    @available(*, deprecated)
    // swiftlint:disable:next strict_fileprivate
    fileprivate init?(bridging action: PONativeAlternativePaymentConfiguration.SecondaryAction) {
        guard case let .cancel(title, disabledFor, confirmation) = action else {
            return nil
        }
        self = .init(title: title, icon: nil, disabledFor: disabledFor, confirmation: confirmation)
    }
}

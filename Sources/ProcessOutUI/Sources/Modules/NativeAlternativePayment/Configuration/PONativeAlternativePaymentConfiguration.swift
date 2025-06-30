//
//  PONativeAlternativePaymentConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import Foundation
import SwiftUI
@_spi(PO) import ProcessOut

// swiftlint:disable strict_fileprivate file_length nesting

/// A configuration object that defines how a native alternative payment view content.
@MainActor
@preconcurrency
public struct PONativeAlternativePaymentConfiguration {

    public enum Flow: Sendable {

        public struct Authorization: Sendable {

            public init(invoiceId: String, gatewayConfigurationId: String) {
                self.invoiceId = invoiceId
                self.gatewayConfigurationId = gatewayConfigurationId
            }

            /// Unique identifier for the invoice associated with this payment request.
            public let invoiceId: String

            /// Identifier of the payment gateway configuration to use for this payment.
            public let gatewayConfigurationId: String
        }

        public struct Tokenization: Sendable {

            public init(customerId: String, customerTokenId: String, gatewayConfigurationId: String) {
                self.customerId = customerId
                self.customerTokenId = customerTokenId
                self.gatewayConfigurationId = gatewayConfigurationId
            }

            /// Customer ID.
            public let customerId: String

            /// Customer token ID.
            public let customerTokenId: String

            /// Gateway configuration identifier.
            public let gatewayConfigurationId: String
        }

        /// Payment authorization flow.
        case authorization(Authorization)

        /// Payment tokenization flow.
        case tokenization(Tokenization)
    }

    /// Payment confirmation configuration.
    @MainActor
    @preconcurrency
    public struct Confirmation {

        /// Boolean value that specifies whether module should wait for payment confirmation from PSP or will
        /// complete right after all user's input is submitted. Default value is `true`.
        @available(*, deprecated, message: "Implementation will always wait for payment confirmation.")
        public var waitsConfirmation: Bool {
            true
        }

        /// Amount of time (in seconds) that module is allowed to wait before receiving final payment confirmation.
        /// Default timeout is 3 minutes while maximum value is 15 minutes.
        public let timeout: TimeInterval

        /// A delay before showing progress view during payment confirmation.
        @available(*, deprecated)
        public let showProgressViewAfter: TimeInterval? = nil

        /// Boolean value indicating whether gateway information (such as name/logo) should stay hidden
        /// during payment confirmation even if more specific payment provider details are not available.
        /// Default value is `false`.
        @available(*, deprecated)
        public let hideGatewayDetails: Bool = false

        /// Payment confirmation button configuration. To remove button use `nil`, this is default behaviour.
        ///
        /// Displays a confirmation button when the user needs to perform an external customer action (e.g.,
        /// completing a step with a third-party service) before proceeding with payment capture. The user
        /// must press this button to continue.
        public let confirmButton: SubmitButton?

        /// Cancel button that could be optionally presented to user during payment confirmation stage. To
        /// remove button use `nil`, this is default behaviour.
        public let cancelButton: CancelButton?

        public init(
            waitsConfirmation: Bool = true,
            timeout: TimeInterval = 180,
            showProgressViewAfter: TimeInterval? = nil,
            hideGatewayDetails: Bool = false,
            confirmButton: SubmitButton? = nil,
            cancelButton: CancelButton? = nil
        ) {
            self.timeout = timeout
            self.confirmButton = confirmButton
            self.cancelButton = cancelButton
        }
    }

    /// Configuration for displaying the payment success screen.
    @MainActor
    @preconcurrency
    public struct Success {

        /// Custom title to display user when payment completes.
        public let title: String?

        /// Custom success message to display user when payment completes.
        public let message: String?

        /// Duration (in seconds) the success screen remains visible when no additional information
        /// is shown. Defaults to 3 seconds.
        public let displayDuration: TimeInterval

        /// Duration (in seconds) the success screen remains visible when additional useful information
        /// is available to the user. Defaults to 60 seconds.
        public let extendedDisplayDuration: TimeInterval

        /// Button configuration allowing the user to manually dismiss the success screen.
        public let doneButton: SubmitButton?

        /// Creates configuration instance.
        public init(
            title: String? = nil,
            message: String? = nil,
            displayDuration: TimeInterval = 3,
            extendedDisplayDuration: TimeInterval = 60,
            doneButton: SubmitButton? = .init()
        ) {
            self.title = title
            self.message = message
            self.displayDuration = displayDuration
            self.extendedDisplayDuration = extendedDisplayDuration
            self.doneButton = doneButton
        }
    }

    /// Configuration options for barcode interaction.
    @MainActor
    @preconcurrency
    public struct BarcodeInteraction {

        /// Button title.
        public let saveButton: SubmitButton

        /// Save error confirmation dialog.
        public let saveErrorConfirmation: POConfirmationDialogConfiguration?

        /// Indicates if haptic feedback is generated during barcode interaction. Feedback is only provided
        /// when the barcode is successfully saved. Default is true.
        public let generateHapticFeedback: Bool

        public init(
            saveButton: SubmitButton = .init(),
            saveErrorConfirmation: POConfirmationDialogConfiguration? = .init(),
            generateHapticFeedback: Bool = true
        ) {
            self.saveButton = saveButton
            self.saveErrorConfirmation = saveErrorConfirmation
            self.generateHapticFeedback = generateHapticFeedback
        }
    }

    /// Button configuration.
    @MainActor
    @preconcurrency
    public struct SubmitButton {

        /// Button title, such as "Pay". Pass `nil` to use default value.
        public let title: String?

        /// Button icon. Pass `nil` to use default value.
        public let icon: AnyView?

        public init<Icon: View>(title: String? = nil, icon: Icon? = AnyView?.none) {
            self.title = title
            self.icon = icon.map(AnyView.init(erasing:))
        }
    }

    /// Cancel button configuration.
    @MainActor
    @preconcurrency
    public struct CancelButton {

        /// Button title. Pass `nil` title to use default value.
        public let title: String?

        /// Button icon. Pass `nil` to use default value.
        public let icon: AnyView?

        /// By default user can interact with button immediately after it becomes visible, it is
        /// possible to make it initially disabled for given amount of time.
        public let disabledFor: TimeInterval

        /// When property is set implementation asks user to confirm cancel.
        public let confirmation: POConfirmationDialogConfiguration?

        /// Controls whether button is hidden.
        let isHidden: Bool

        /// Creates cancel button configuration.
        public init<Icon: View>(
            title: String? = nil,
            icon: Icon? = AnyView?.none,
            disabledFor: TimeInterval = 0,
            confirmation: POConfirmationDialogConfiguration? = nil
        ) {
            self.title = title
            self.icon = icon.map(AnyView.init(erasing:))
            self.disabledFor = disabledFor
            self.confirmation = confirmation
            isHidden = false
        }

        /// Creates cancel button configuration.
        init<Icon: View>(
            title: String? = nil,
            icon: Icon? = AnyView?.none,
            disabledFor: TimeInterval = 0,
            confirmation: POConfirmationDialogConfiguration? = nil,
            isHidden: Bool
        ) {
            self.title = title
            self.icon = icon.map(AnyView.init(erasing:))
            self.disabledFor = disabledFor
            self.confirmation = confirmation
            self.isHidden = isHidden
        }
    }

    /// Payment flow.
    public let flow: Flow

    /// Custom title.
    public let title: String?

    /// A Boolean property that indicates whether the code input should be horizontally centered. This property
    /// is only applicable when there is a single code input. If there are multiple inputs the alignment is always
    /// leading. Default value is `false`.
    @available(*, deprecated)
    public let shouldHorizontallyCenterCodeInput: Bool = false

    /// For parameters where user should select single option from multiple values defines
    /// maximum number of options that framework will display inline (e.g. using radio buttons).
    ///
    /// Default value is `5`.
    public let inlineSingleSelectValuesLimit: Int

    /// Barcode interaction configuration.
    public let barcodeInteraction: BarcodeInteraction

    /// Submit button configuration.
    public let submitButton: SubmitButton

    /// Cancel button configuration.
    public let cancelButton: CancelButton?

    /// Payment confirmation configuration.
    public let paymentConfirmation: Confirmation

    /// Payment success screen configuration. In order to avoid showing success screen to user pass `nil`.
    public let success: Success?

    /// Creates configuration.
    public init(
        flow: Flow,
        title: String? = nil,
        shouldHorizontallyCenterCodeInput: Bool = true,
        inlineSingleSelectValuesLimit: Int = 5,
        barcodeInteraction: BarcodeInteraction = .init(),
        submitButton: SubmitButton = .init(),
        cancelButton: CancelButton? = nil,
        paymentConfirmation: Confirmation = .init(),
        success: Success? = .init()
    ) {
        self.flow = flow
        self.title = title
        self.inlineSingleSelectValuesLimit = inlineSingleSelectValuesLimit
        self.submitButton = submitButton
        self.cancelButton = cancelButton
        self.paymentConfirmation = paymentConfirmation
        self.success = success
        self.barcodeInteraction = barcodeInteraction
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

    /// Invoice that should be authorized/captured.
    @available(*, deprecated, message: "Use flow instead.")
    public var invoiceId: String {
        switch flow {
        case .authorization(let flow):
            return flow.invoiceId
        case .tokenization:
            return ""
        }
    }

    /// Gateway configuration id that should be used to initiate native alternative payment.
    @available(*, deprecated, message: "Use flow instead.")
    public var gatewayConfigurationId: String {
        switch flow {
        case .authorization(let flow):
            return flow.gatewayConfigurationId
        case .tokenization(let flow):
            return flow.gatewayConfigurationId
        }
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
        self.flow = .authorization(.init(invoiceId: invoiceId, gatewayConfigurationId: gatewayConfigurationId))
        self.title = title
        self.success = skipSuccessScreen ? nil : .init(message: successMessage)
        self.submitButton = .init(title: primaryActionTitle)
        self.cancelButton = secondaryAction.flatMap { .init(bridging: $0) }
        self.inlineSingleSelectValuesLimit = inlineSingleSelectValuesLimit
        self.paymentConfirmation = .init(
            waitsConfirmation: waitsPaymentConfirmation,
            timeout: paymentConfirmationTimeout,
            secondaryAction: paymentConfirmationSecondaryAction
        )
        self.barcodeInteraction = .init()
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
        self.flow = .authorization(.init(invoiceId: invoiceId, gatewayConfigurationId: gatewayConfigurationId))
        self.title = title
        self.success = skipSuccessScreen ? nil : .init(message: successMessage)
        self.submitButton = .init(title: primaryActionTitle)
        self.cancelButton = secondaryAction.flatMap { .init(bridging: $0) }
        self.inlineSingleSelectValuesLimit = inlineSingleSelectValuesLimit
        self.paymentConfirmation = paymentConfirmation
        self.barcodeInteraction = .init()
    }

    /// Creates configuration.
    @available(*, deprecated, message: "Use init that accepts flow instead.")
    public init(
        invoiceId: String,
        gatewayConfigurationId: String,
        title: String? = nil,
        shouldHorizontallyCenterCodeInput: Bool = true,
        inlineSingleSelectValuesLimit: Int = 5,
        barcodeInteraction: BarcodeInteraction = .init(),
        submitButton: SubmitButton = .init(),
        cancelButton: CancelButton? = nil,
        paymentConfirmation: Confirmation = .init(),
        success: Success? = .init()
    ) {
        self.flow = .authorization(.init(invoiceId: invoiceId, gatewayConfigurationId: gatewayConfigurationId))
        self.title = title
        self.inlineSingleSelectValuesLimit = inlineSingleSelectValuesLimit
        self.submitButton = submitButton
        self.cancelButton = cancelButton
        self.paymentConfirmation = paymentConfirmation
        self.success = success
        self.barcodeInteraction = barcodeInteraction
    }
}

extension PONativeAlternativePaymentConfiguration.Confirmation {

    @available(*, deprecated)
    public typealias ConfirmButton = PONativeAlternativePaymentConfiguration.SubmitButton

    /// Action that could be optionally presented to user during payment confirmation stage. To remove action
    /// use `nil`, this is default behaviour.
    @available(*, deprecated)
    public var secondaryAction: PONativeAlternativePaymentConfiguration.SecondaryAction? {
        cancelButton.map { .cancel(title: $0.title, disabledFor: $0.disabledFor, confirmation: $0.confirmation) }
    }

    /// A delay before showing progress view during payment confirmation.
    @available(*, deprecated, renamed: "showProgressViewAfter")
    public var showProgressIndicatorAfter: TimeInterval? {
        showProgressViewAfter
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
        self.timeout = timeout
        self.confirmButton = confirmButton
        self.cancelButton = secondaryAction.flatMap { .init(bridging: $0) }
    }
}

extension PONativeAlternativePaymentConfiguration.CancelButton {

    @available(*, deprecated)
    fileprivate init?(bridging action: PONativeAlternativePaymentConfiguration.SecondaryAction) {
        guard case let .cancel(title, disabledFor, confirmation) = action else {
            return nil
        }
        self = .init(title: title, disabledFor: disabledFor, confirmation: confirmation)
    }
}

extension PONativeAlternativePaymentConfiguration.Success {

    /// Duration (in seconds) the success screen remains visible when no additional information
    /// is shown.
    @available(*, deprecated, renamed: "displayDuration")
    public var duration: TimeInterval {
        displayDuration
    }
}

// swiftlint:enable strict_fileprivate file_length nesting

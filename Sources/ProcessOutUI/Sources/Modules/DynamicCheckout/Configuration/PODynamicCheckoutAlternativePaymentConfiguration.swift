//
//  PODynamicCheckoutAlternativePaymentConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import Foundation
import SwiftUI

/// Alternative payment specific dynamic checkout configuration.
@_spi(PO)
@MainActor
public struct PODynamicCheckoutAlternativePaymentConfiguration: Sendable {

    @MainActor
    public struct PaymentConfirmation: Sendable {

        /// Amount of time (in seconds) that module is allowed to wait before receiving final payment confirmation.
        /// Default timeout is 3 minutes while maximum value is 15 minutes.
        public let timeout: TimeInterval

        /// A delay before showing progress indicator during payment confirmation.
        public let showProgressViewAfter: TimeInterval?

        /// Payment confirmation button configuration.
        ///
        /// Displays a confirmation button when the user needs to perform an external customer action (e.g.,
        /// completing a step with a third-party service) before proceeding with payment capture. The user
        /// must press this button to continue.
        public let confirmButton: SubmitButton?

        /// Action that could be optionally presented to user during payment confirmation stage. To remove action
        /// use `nil`, this is default behaviour.
        public let cancelButton: CancelButton?

        /// Creates confirmation configuration.
        public init(
            timeout: TimeInterval = 180,
            showProgressViewAfter: TimeInterval? = nil,
            confirmButton: SubmitButton? = nil,
            cancelButton: CancelButton? = nil
        ) {
            self.timeout = timeout
            self.showProgressViewAfter = showProgressViewAfter
            self.confirmButton = confirmButton
            self.cancelButton = cancelButton
        }
    }

    /// Configuration options for barcode interaction.
    @MainActor
    public struct BarcodeInteraction: Sendable {

        /// Save button configuration.
        public let saveButton: SubmitButton

        /// Save error confirmation dialog.
        public let saveErrorConfirmation: POConfirmationDialogConfiguration?

        /// Indicates if haptic feedback is generated during barcode interaction. Feedback is only provided
        /// when the barcode is successfully saved. Default is true.
        public let generateHapticFeedback: Bool

        public init(
            saveButton: SubmitButton? = nil,
            saveErrorConfirmation: POConfirmationDialogConfiguration? = nil,
            generateHapticFeedback: Bool = true
        ) {
            self.saveButton = saveButton ?? .init()
            self.saveErrorConfirmation = saveErrorConfirmation
            self.generateHapticFeedback = generateHapticFeedback
        }
    }

    /// Submit button configuration.
    @MainActor
    public struct SubmitButton: Sendable {

        /// Button title.
        public let title: String?

        /// Button icon.
        public let icon: AnyView?

        /// Creates button instance.
        public init(title: String? = nil, icon: AnyView? = nil) {
            self.title = title
            self.icon = icon
        }
    }

    @MainActor
    public struct CancelButton: Sendable {

        /// Cancel button title. Use `nil` for default title.
        public let title: String?

        /// Button icon.
        public let icon: AnyView?

        /// By default user can interact with action immediately after it becomes visible, it is
        /// possible to make it initially disabled for given amount of time.
        public let disabledFor: TimeInterval

        /// When property is set implementation asks user to confirm cancel.
        public let confirmation: POConfirmationDialogConfiguration?

        public init(
            title: String? = nil,
            icon: AnyView? = nil,
            disabledFor: TimeInterval = 0,
            confirmation: POConfirmationDialogConfiguration? = nil
        ) {
            self.title = title
            self.icon = icon
            self.disabledFor = disabledFor
            self.confirmation = confirmation
        }
    }

    /// For parameters where user should select single option from multiple values defines
    /// maximum number of options that framework will display inline (e.g. using radio buttons).
    ///
    /// Default value is `5`.
    public let inlineSingleSelectValuesLimit: Int

    /// Barcode interaction configuration.
    public let barcodeInteraction: BarcodeInteraction

    /// Payment confirmation configuration for payment method where available.
    public let paymentConfirmation: PaymentConfirmation

    /// Creates configuration.
    public init(
        inlineSingleSelectValuesLimit: Int = 5,
        barcodeInteraction: BarcodeInteraction = .init(),
        paymentConfirmation: PaymentConfirmation = .init()
    ) {
        self.inlineSingleSelectValuesLimit = inlineSingleSelectValuesLimit
        self.barcodeInteraction = barcodeInteraction
        self.paymentConfirmation = paymentConfirmation
    }
}

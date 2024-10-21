//
//  PONativeAlternativePaymentConfirmation.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.03.2024.
//

import Foundation

/// Configuration specific to native APM payment confirmation.
public struct PONativeAlternativePaymentConfirmationConfiguration { // swiftlint:disable:this type_name

    /// Configuration options for barcode interaction.
    public struct BarcodeInteraction {

        /// Button title.
        public let saveButtonTitle: String?

        /// Save error confirmation dialog.
        /// - NOTE: Secondary action is ignored.
        public let saveErrorConfirmation: POConfirmationDialogConfiguration?
    }

    /// Confirmation button configuration.
    public struct ConfirmButton {

        /// Button title.
        public let title: String?

        /// Creates button instance.
        public init(title: String? = nil) {
            self.title = title
        }
    }

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

    /// Barcode interaction configuration.
    public let barcodeInteraction: BarcodeInteraction?

    /// Payment confirmation button configuration.
    ///
    /// Displays a confirmation button when the user needs to perform an external customer action (e.g.,
    /// completing a step with a third-party service) before proceeding with payment capture. The user
    /// must press this button to continue.
    public let confirmButton: ConfirmButton?

    /// Action that could be optionally presented to user during payment confirmation stage. To remove action
    /// use `nil`, this is default behaviour.
    public let secondaryAction: PONativeAlternativePaymentConfiguration.SecondaryAction?

    /// Creates configuration instance.
    public init(
        waitsConfirmation: Bool = true,
        timeout: TimeInterval = 180,
        showProgressIndicatorAfter: TimeInterval? = nil,
        hideGatewayDetails: Bool = false,
        barcodeInteraction: BarcodeInteraction? = nil,
        confirmButton: ConfirmButton? = nil,
        secondaryAction: PONativeAlternativePaymentConfiguration.SecondaryAction? = nil
    ) {
        self.waitsConfirmation = waitsConfirmation
        self.timeout = timeout
        self.showProgressIndicatorAfter = showProgressIndicatorAfter
        self.hideGatewayDetails = hideGatewayDetails
        self.barcodeInteraction = barcodeInteraction
        self.confirmButton = confirmButton
        self.secondaryAction = secondaryAction
    }
}

//
//  ButtonViewModel+Confirmation.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.11.2024.
//

@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

extension POButtonViewModel.Confirmation {

    static func paymentCancel(
        with configuration: POConfirmationDialogConfiguration,
        localization: LocalizationConfiguration,
        onAppear: (() -> Void)? = nil
    ) -> Self {
        let confirmation = POButtonViewModel.Confirmation(
            title: configuration.title ?? String(
                resource: .PaymentCancelConfirmation.title, configuration: localization
            ),
            message: configuration.message,
            confirmButtonTitle: configuration.confirmActionTitle
                ?? String(resource: .PaymentCancelConfirmation.confirm, configuration: localization),
            cancelButtonTitle: configuration.cancelActionTitle ?? String(
                resource: .PaymentCancelConfirmation.cancel, configuration: localization
            ),
            onAppear: onAppear
        )
        return confirmation
    }

    static func cancel(
        with configuration: POConfirmationDialogConfiguration,
        localization: LocalizationConfiguration,
        onAppear: (() -> Void)? = nil
    ) -> Self {
        let confirmation = POButtonViewModel.Confirmation(
            title: configuration.title ?? String(resource: .CancelConfirmation.title, configuration: localization),
            message: configuration.message,
            confirmButtonTitle: configuration.confirmActionTitle ?? String(
                resource: .CancelConfirmation.confirm, configuration: localization
            ),
            cancelButtonTitle: configuration.cancelActionTitle ?? String(
                resource: .CancelConfirmation.cancel, configuration: localization
            ),
            onAppear: onAppear
        )
        return confirmation
    }

    static func delete(
        with configuration: POConfirmationDialogConfiguration,
        localization: LocalizationConfiguration,
        onAppear: (() -> Void)? = nil
    ) -> Self {
        let confirmation = POButtonViewModel.Confirmation(
            title: configuration.title ?? String(resource: .DeleteConfirmation.title, configuration: localization),
            message: configuration.message,
            confirmButtonTitle: configuration.confirmActionTitle ?? String(
                resource: .DeleteConfirmation.confirm, configuration: localization
            ),
            cancelButtonTitle: configuration.cancelActionTitle ?? String(
                resource: .DeleteConfirmation.cancel, configuration: localization
            ),
            onAppear: onAppear
        )
        return confirmation
    }
}

extension POStringResource {

    enum PaymentCancelConfirmation {

        /// Confirmation title.
        static let title = POStringResource("payment-cancel-confirmation.title", comment: "")

        /// Confirm button title.
        static let confirm = POStringResource("payment-cancel-confirmation.confirm", comment: "")

        /// Cancel button title.
        static let cancel = POStringResource("payment-cancel-confirmation.cancel", comment: "")
    }

    enum CancelConfirmation {

        /// Confirmation title.
        static let title = POStringResource("cancel-confirmation.title", comment: "")

        /// Confirm button title.
        static let confirm = POStringResource("cancel-confirmation.confirm", comment: "")

        /// Cancel button title.
        static let cancel = POStringResource("cancel-confirmation.cancel", comment: "")
    }

    enum DeleteConfirmation {

        /// Confirmation title.
        static let title = POStringResource("delete-confirmation.title", comment: "")

        /// Confirm button title.
        static let confirm = POStringResource("delete-confirmation.confirm", comment: "")

        /// Cancel button title.
        static let cancel = POStringResource("delete-confirmation.cancel", comment: "")
    }
}

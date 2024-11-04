//
//  ButtonViewModel+CancelConfirmation.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.11.2024.
//

@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

extension POButtonViewModel.Confirmation {

    static func cancel(with configuration: POConfirmationDialogConfiguration) -> Self {
        .init(
            title: configuration.title ?? String(resource: .CancelConfirmation.title),
            message: configuration.message,
            confirmButtonTitle: configuration.confirmActionTitle ?? String(resource: .CancelConfirmation.confirm),
            cancelButtonTitle: configuration.cancelActionTitle ?? String(resource: .CancelConfirmation.cancel)
        )
    }
}

extension POStringResource {

    enum CancelConfirmation {

        /// Confirmation title.
        static let title = POStringResource("cancel-confirmation.title", comment: "")

        /// Confirm button title.
        static let confirm = POStringResource("cancel-confirmation.confirm", comment: "")

        /// Cancel button title.
        static let cancel = POStringResource("cancel-confirmation.cancel", comment: "")
    }
}

//
//  POConfirmationDialogConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 21.05.2024.
//

public struct POConfirmationDialogConfiguration {

    /// Confirmation title. Use empty string to hide title.
    public let title: String?

    /// Message. Use empty string to hide message.
    public let message: String?

    /// Button that confirms action.
    public let confirmActionTitle: String?

    /// Button that aborts action.
    public let cancelActionTitle: String?

    public init(
        title: String? = nil,
        message: String? = nil,
        confirmActionTitle: String? = nil,
        cancelActionTitle: String? = nil
    ) {
        self.title = title
        self.message = message
        self.confirmActionTitle = confirmActionTitle
        self.cancelActionTitle = cancelActionTitle
    }
}

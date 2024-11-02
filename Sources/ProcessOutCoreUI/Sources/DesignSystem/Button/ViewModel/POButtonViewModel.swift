//
//  POButtonViewModel.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import Foundation

@_spi(PO)
public struct POButtonViewModel: Identifiable {

    /// Confirmation dialog configuration.
    public struct Confirmation: Sendable {

        /// Confirmation title. Use empty string to hide title.
        public let title: String

        /// Message. Use empty string to hide message.
        public let message: String?

        /// Button that confirms action.
        public let confirmButtonTitle: String

        /// Button that aborts action.
        public let cancelButtonTitle: String

        public init(title: String, message: String?, confirmButtonTitle: String, cancelButtonTitle: String) {
            self.title = title
            self.message = message
            self.confirmButtonTitle = confirmButtonTitle
            self.cancelButtonTitle = cancelButtonTitle
        }
    }

    /// Identifier.
    public let id: String

    /// Action title.
    public let title: String

    /// Boolean value indicating whether action is enabled.
    public let isEnabled: Bool

    /// Boolean value indicating whether button should display loading indicator.
    public let isLoading: Bool

    /// A value that describes the purpose of a button.
    public let role: POButtonRole?

    /// Confirmation dialog to present to user before invoking action.
    public let confirmation: Confirmation?

    /// Action handler.
    public let action: @MainActor () -> Void

    /// Creates view model with given parameters.
    public init(
        id: String,
        title: String,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        role: POButtonRole? = nil,
        confirmation: Confirmation? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.id = id
        self.title = title
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.role = role
        self.confirmation = confirmation
        self.action = action
    }
}

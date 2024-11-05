//
//  POButtonViewModel.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import Foundation
import SwiftUI

@_spi(PO)
@MainActor
public struct POButtonViewModel: Identifiable {

    /// Confirmation dialog configuration.
    @MainActor
    public struct Confirmation {

        /// Confirmation title. Use empty string to hide title.
        public let title: String

        /// Message. Use empty string to hide message.
        public let message: String?

        /// Button that confirms action.
        public let confirmButtonTitle: String

        /// Button that aborts action.
        public let cancelButtonTitle: String

        /// Action to invoke when confirmation appears.
        public let onAppear: (() -> Void)?

        public init(
            title: String,
            message: String?,
            confirmButtonTitle: String,
            cancelButtonTitle: String,
            onAppear: (() -> Void)?
        ) {
            self.title = title
            self.message = message
            self.confirmButtonTitle = confirmButtonTitle
            self.cancelButtonTitle = cancelButtonTitle
            self.onAppear = onAppear
        }
    }

    /// Identifier.
    public nonisolated let id: String

    /// Action title.
    public let title: String

    /// Icon view.
    public let icon: AnyView?

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
        icon: AnyView? = nil,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        role: POButtonRole? = nil,
        confirmation: Confirmation? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.role = role
        self.confirmation = confirmation
        self.action = action
    }
}

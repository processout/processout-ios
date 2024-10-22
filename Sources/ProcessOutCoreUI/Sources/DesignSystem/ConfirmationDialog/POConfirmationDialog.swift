//
//  POConfirmationDialog.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.05.2024.
//

import Foundation

@_spi(PO)
public struct POConfirmationDialog {

    public struct Button {

        /// Button title.
        public let title: String

        /// An optional semantic role that describes the button.
        public let role: ButtonRole?

        /// The action to perform when the user interacts with the button.
        public let action: (() -> Void)?

        /// Creates a button
        public init(title: String, role: ButtonRole? = nil, action: (() -> Void)? = nil) {
            self.title = title
            self.role = role
            self.action = action
        }
    }

    public enum ButtonRole {

        /// A role that indicates a destructive button.
        case destructive

        /// A role that indicates a button that cancels an operation.
        case cancel
    }

    /// Dialog title.
    public let title: String

    /// Optional message.
    public let message: String?

    /// Primary button.
    public let primaryButton: Button

    /// Secondary button.
    public let secondaryButton: Button?

    /// Creates confirmation dialog instance.
    public init(title: String, message: String? = nil, primaryButton: Button, secondaryButton: Button? = nil) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
}

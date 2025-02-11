//
//  POCardScannerConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.12.2024.
//

import SwiftUI

/// Card scanner view configuration.
@MainActor
public struct POCardScannerConfiguration {

    /// Cancel button configuration.
    @MainActor
    public struct CancelButton {

        /// Button title. Pass `nil` title to use default value.
        public let title: String?

        /// Button icon. Pass `nil` title to use default value.
        public let icon: AnyView?

        /// When property is set implementation asks user to confirm cancel.
        public let confirmation: POConfirmationDialogConfiguration?

        /// Creates cancel button configuration.
        public init<Icon: View>(
            title: String? = nil,
            icon: Icon? = AnyView?.none,
            confirmation: POConfirmationDialogConfiguration? = nil
        ) {
            self.title = title
            self.icon = icon.map(AnyView.init(erasing:))
            self.confirmation = confirmation
        }
    }

    /// Custom title. Use empty string to hide title.
    public let title: String?

    /// Custom description. Use empty string to hide description.
    public let description: String?

    /// Cancel button configuration.
    public let cancelButton: CancelButton?

    public init(title: String? = nil, description: String? = nil, cancelButton: CancelButton? = .init()) {
        self.title = title
        self.description = description
        self.cancelButton = cancelButton
    }
}

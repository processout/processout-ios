//
//  POButtonViewModel.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import Foundation

@_spi(PO)
public struct POButtonViewModel: Identifiable {

    /// Creates view model with given parameters.
    public init(
        id: String,
        title: String,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        role: POButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.role = role
        self.action = action
    }

    public let id: String

    /// Action title.
    public let title: String

    /// Boolean value indicating whether action is enabled.
    public let isEnabled: Bool

    /// Boolean value indicating whether button should display loading indicator.
    public let isLoading: Bool

    /// A value that describes the purpose of a button.
    public let role: POButtonRole?

    /// Action handler.
    public let action: () -> Void
}

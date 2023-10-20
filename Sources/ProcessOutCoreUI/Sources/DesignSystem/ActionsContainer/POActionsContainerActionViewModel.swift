//
//  POActionsContainerActionViewModel.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import Foundation

@_spi(PO) public struct POActionsContainerActionViewModel: Identifiable {

    /// Creates view model with given parameters.
    public init(
        id: String, title: String, isEnabled: Bool, isLoading: Bool, isPrimary: Bool, action: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.isPrimary = isPrimary
        self.action = action
    }

    public let id: String

    /// Action title.
    public let title: String

    /// Boolean value indicating whether action is enabled.
    public let isEnabled: Bool

    /// Boolean value indicating whether button should display loading indicator.
    public let isLoading: Bool

    /// Defines whether button is primary which changes button's appearance.
    public let isPrimary: Bool

    /// Action handler.
    public let action: () -> Void
}

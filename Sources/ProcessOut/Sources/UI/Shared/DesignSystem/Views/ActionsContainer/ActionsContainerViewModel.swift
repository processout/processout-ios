//
//  ActionsContainerViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.08.2023.
//

struct ActionsContainerViewModel {

    /// Primary action.
    let primary: ActionsContainerActionViewModel?

    /// Secondary action.
    let secondary: ActionsContainerActionViewModel?
}

struct ActionsContainerActionViewModel {

    /// Action title.
    let title: String

    /// Boolean value indicating whether action is enabled.
    let isEnabled: Bool

    /// Boolean value indicating whether action associated with button is currently running.
    let isExecuting: Bool

    /// Accessibility identifier.
    let accessibilityIdentifier: String

    /// Action handler.
    let handler: () -> Void
}

//
//  View+OnSubmit.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 05.10.2023.
//

import SwiftUI

extension POBackport where Wrapped: Any {

    @MainActor
    struct SubmitAction {

        nonisolated init() {
            // Nothing to do
        }

        mutating func append(action: @escaping () -> Void) {
            actions.append(action)
        }

        func callAsFunction() {
            actions.forEach { $0() }
        }

        // MARK: - Private Properties

        private var actions: [() -> Void] = []
    }
}

extension POBackport where Wrapped: View {

    /// Adds an action to perform when the user submits a value to this view.
    /// - NOTE: Only works with `POTextField`.
    public func onSubmit(_ action: @escaping () -> Void) -> some View {
        wrapped.transformEnvironment(\.backportSubmitAction) { $0.append(action: action) }
    }
}

extension EnvironmentValues {

    /// Submit action.
    @Entry
    var backportSubmitAction = POBackport<Any>.SubmitAction()
}

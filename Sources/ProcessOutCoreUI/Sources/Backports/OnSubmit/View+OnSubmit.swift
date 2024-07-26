//
//  View+OnSubmit.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 05.10.2023.
//

import SwiftUI

extension POBackport where Wrapped: Any {

    @MainActor
    final class SubmitAction: Sendable {

        typealias Action = () -> Void // swiftlint:disable:this nesting

        nonisolated init() {
            actions = []
        }

        func callAsFunction() {
            actions.forEach { $0() }
        }

        func append(action: @escaping Action) {
            actions.append(action)
        }

        // MARK: - Private Properties

        private nonisolated(unsafe) var actions: [Action]
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

    var backportSubmitAction: POBackport<Any>.SubmitAction {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Properties

    private struct Key: EnvironmentKey {
        static let defaultValue = POBackport<Any>.SubmitAction()
    }
}

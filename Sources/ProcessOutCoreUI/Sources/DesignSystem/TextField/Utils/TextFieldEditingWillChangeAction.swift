//
//  TextFieldEditingDidChangeAction.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.05.2025.
//

import SwiftUI

@MainActor
struct TextFieldEditingDidChangeAction {

    nonisolated init() {
        // Nothing to do
    }

    mutating func append(action: @escaping (_ proposedValue: String) -> Void) {
        actions.append(action)
    }

    func callAsFunction(proposedValue: String) {
        actions.forEach { $0(proposedValue) }
    }

    // MARK: - Private Properties

    private var actions: [(String) -> Void] = []
}

extension View {

    /// Adds an action to perform when editing changes preserving originally proposed value.
    /// - NOTE: Only works with `POTextField`.
    public func onTextFieldEditingDidChange(_ action: @escaping (String) -> Void) -> some View {
        transformEnvironment(\.textFieldEditingDidChangeAction) { $0.append(action: action) }
    }
}

extension EnvironmentValues {

    /// Submit action.
    var textFieldEditingDidChangeAction: TextFieldEditingDidChangeAction {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    private struct Key: EnvironmentKey {
        static let defaultValue = TextFieldEditingDidChangeAction()
    }
}

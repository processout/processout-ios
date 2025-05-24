//
//  TextFieldEditingWillChangeAction.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.05.2025.
//

import SwiftUI

@MainActor
struct TextFieldEditingWillChangeAction {

    nonisolated init() {
        // Nothing to do
    }

    mutating func append(action: @escaping (_ newValue: String) -> Void) {
        actions.append(action)
    }

    func callAsFunction(newValue: String) {
        actions.forEach { $0(newValue) }
    }

    // MARK: - Private Properties

    private var actions: [(String) -> Void] = []
}

extension View {

    /// Adds an action to perform when editing is about to change.
    /// - NOTE: Only works with `POTextField`.
    public func onTextFieldEditingWillChange(_ action: @escaping (String) -> Void) -> some View {
        transformEnvironment(\.textFieldEditingWillChangeAction) { $0.append(action: action) }
    }
}

extension EnvironmentValues {

    /// Submit action.
    var textFieldEditingWillChangeAction: TextFieldEditingWillChangeAction {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    private struct Key: EnvironmentKey {
        static let defaultValue = TextFieldEditingWillChangeAction()
    }
}

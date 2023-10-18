//
//  View+OnSubmit.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 05.10.2023.
//

import SwiftUI

extension POBackport where Wrapped: View {

    /// Adds an action to perform when the user submits a value to this view.
    /// - NOTE: Only works with `POTextField`.
    public func onSubmit(_ action: @escaping () -> Void) -> some View {
        wrapped.environment(\.backportSubmitAction, action)
    }
}

extension EnvironmentValues {

    var backportSubmitAction: (() -> Void)? {
        get {
            self[Key.self]
        }
        set {
            let oldValue = backportSubmitAction
            let box = {
                oldValue?()
                newValue?()
            }
            self[Key.self] = box
        }
    }

    // MARK: - Private Properties

    private struct Key: EnvironmentKey {
        static let defaultValue: (() -> Void)? = nil
    }
}

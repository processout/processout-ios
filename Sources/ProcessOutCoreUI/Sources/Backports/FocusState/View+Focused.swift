//
//  View+Focused.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 03.10.2023.
//

import SwiftUI

extension POBackport where Wrapped: View {

    /// Modifies this view by binding its focus state to the given state value.
    /// - NOTE: Only works with `POTextField` and `POCodeField`.
    @available(iOS 14, *)
    public func focused<Value: Hashable>(_ binding: Binding<Value?>, equals value: Value) -> some View {
        wrapped.modifier(FocusModifier(binding: binding, value: value))
    }

    /// Modifies this view by binding its focus state to the given Boolean state
    /// value.
    /// - NOTE: Only works with `POTextField` and `POCodeField`.
    @available(iOS 14, *)
    public func focused(_ condition: Binding<Bool>) -> some View {
        let binding = Binding<Bool?>(
            get: { condition.wrappedValue },
            set: { condition.wrappedValue = $0 ?? false }
        )
        return focused(binding, equals: true)
    }
}

@available(iOS 14, *)
@MainActor
private struct FocusModifier<Value: Hashable>: ViewModifier {

    /// The state binding to register.
    @Binding
    private(set) var binding: Value?

    /// The value to match against when determining whether the binding should change.
    let value: Value

    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        content
            .onDidAppear {
                isVisible = true
            }
            .onDisappear {
                isVisible = false
            }
            .backport.onChange(of: binding) {
                updateFirstResponder()
            }
            .backport.onChange(of: coordinator.isEditing) {
                if coordinator.isEditing {
                    binding = value
                } else if binding == value {
                    binding = nil
                }
            }
            .backport.onChange(of: isVisible) {
                updateFirstResponder()
            }
            .environmentObject(coordinator)
    }

    // MARK: - Private Properties

    /// Indicates whether
    @State
    private var isVisible = false

    @StateObject
    private var coordinator = FocusCoordinator()

    // MARK: - Private Methods

    private func updateFirstResponder() {
        if isVisible {
            if binding == value {
                coordinator.beginEditing()
            } else if binding == nil {
                coordinator.endEditing()
            }
        } else if binding == value {
            binding = nil
        }
    }
}

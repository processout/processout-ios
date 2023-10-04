//
//  View+OnChange.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 03.10.2023.
//

import SwiftUI
import Combine

extension POBackport where Wrapped: View {

    /// Adds a modifier for this view that fires an action when a specific value changes.
    @available(iOS, deprecated: 17.0)
    @ViewBuilder
    public func onChange<Value: Equatable>(of value: Value, perform action: @escaping () -> Void) -> some View {
        if #available(iOS 17, *) {
            wrapped.onChange(of: value, action)
        } else {
            wrapped.modifier(Modifier(value: value, action: action))
        }
    }
}

private struct Modifier<Value: Equatable>: ViewModifier {

    init(value: Value, action: @escaping () -> Void) {
        self.value = value
        self.action = action
        _oldValue = .init(initialValue: value)
    }

    func body(content: Content) -> some View {
        content.onReceive(Just(value)) { newValue in
            guard newValue != oldValue else {
                return
            }
            oldValue = newValue
            action()
        }
    }

    // MARK: - Private Properties

    private let value: Value
    private let action: () -> Void

    @State private var oldValue: Value?
}

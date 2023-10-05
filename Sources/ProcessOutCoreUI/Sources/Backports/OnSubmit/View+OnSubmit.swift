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
        wrapped.modifier(SubmitModifier(action: action))
    }
}

private struct SubmitModifier: ViewModifier {

    init(action: @escaping () -> Void) {
        _coordinator = .init(wrappedValue: .init(onSubmit: action))
    }

    func body(content: Content) -> some View {
        content
            .onReceive(Constants.didBeginEditingPublisher) { output in
                if let textField = output.object as? UITextField, textField.inputIdentifier == inputIdentifier {
                    coordinator.configure(textField: textField)
                }
            }
            .onDisappear {
                coordinator.clean()
            }
            .onPreferenceChange(InputIdentifierPreferenceKey.self) { id in
                inputIdentifier = id
            }
    }

    // MARK: -

    private enum Constants {
        static let didBeginEditingPublisher = NotificationCenter.default.publisher(
            for: UITextField.textDidBeginEditingNotification
        )
    }

    // MARK: - Private Properties

    @POBackport.StateObject
    private var coordinator: Coordinator

    @State
    private var inputIdentifier: String?
}

private final class Coordinator: ObservableObject {

    init(onSubmit: @escaping () -> Void) {
        self.onSubmit = onSubmit
    }

    func configure(textField: UITextField) {
        clean()
        textField.addTarget(self, action: #selector(editingDidEndOnExit), for: .editingDidEndOnExit)
        self.textField = textField
    }

    func clean() {
        textField?.removeTarget(self, action: nil, for: .allEvents)
    }

    // MARK: - Private Properties

    private let onSubmit: () -> Void
    private weak var textField: UITextField?

    // MARK: - Private Methods

    @objc private func editingDidEndOnExit() {
        onSubmit()
    }
}

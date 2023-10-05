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

    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(Constants.didEndEditingPublisher) { output in
                guard let reasonRawValue = output.userInfo?[UITextField.didEndEditingReasonUserInfoKey] as? Int,
                      let control = output.object as? UIView else {
                    return
                }
                let reason = UITextField.DidEndEditingReason(rawValue: reasonRawValue)
                if reason == .committed, focusableIdentifier == control.inputIdentifier {
                    action()
                }
            }
            .onPreferenceChange(InputIdentifierPreferenceKey.self) { id in
                focusableIdentifier = id
            }
    }

    // MARK: -

    private enum Constants {
        static let didEndEditingPublisher = NotificationCenter.default.publisher(
            for: UITextField.textDidEndEditingNotification
        )
    }

    // MARK: - Private Properties

    @State
    private var focusableIdentifier: String?
}

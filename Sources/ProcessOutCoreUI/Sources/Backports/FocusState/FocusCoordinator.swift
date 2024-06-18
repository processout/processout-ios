//
//  FocusCoordinator.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 09.10.2023.
//

import SwiftUI

final class FocusCoordinator: ObservableObject {

    /// Holds boolean value indicating whether tracked control is currently being edited.
    @Published private(set) var isEditing = false

    func track(control: UIControl) {
        guard self.control == nil else {
            return
        }
        control.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        control.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
        self.control = control
    }

    func beginEditing() {
        guard let control, !control.isFirstResponder else {
            return
        }
        assert(control.window != nil, "Window must be set.")
        control.becomeFirstResponder()
    }

    func endEditing() {
        guard let control, control.isFirstResponder else {
            return
        }
        assert(control.window != nil, "Window must be set.")
        control.endEditing(true)
    }

    // MARK: - Private Properties

    private weak var control: UIControl?

    // MARK: - Private Methods

    @objc private func editingDidBegin() {
        isEditing = true
    }

    @objc private func editingDidEnd() {
        isEditing = false
    }
}

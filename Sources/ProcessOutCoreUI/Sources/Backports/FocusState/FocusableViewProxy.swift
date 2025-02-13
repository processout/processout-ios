//
//  FocusableViewProxy.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.01.2025.
//

import UIKit

struct FocusableViewProxy: @unchecked Sendable {

    /// - NOTE: Proxy won't track changes to responder state automatically.
    @MainActor
    init(uiControl: UIControl) {
        self.id = ObjectIdentifier(uiControl)
        self.uiControl = uiControl
        isFocused = uiControl.isFirstResponder
    }

    init() {
        id = AnyHashable(nil as ObjectIdentifier?)
        isFocused = false
    }

    /// Underlying focusable view ID.
    let id: AnyHashable

    /// Boolean value indicating whether is currently focused. Nil indicates that value
    /// is unknown probably because there is no underlying focusable view.
    let isFocused: Bool

    /// Changes focus state of underlying focusable view if any.
    @discardableResult
    @MainActor
    func setFocused(_ focused: Bool) -> Bool {
        guard let uiControl else {
            return false // Ignoring attempt to change focus state, control is not set.
        }
        assert(uiControl.window != nil, "Window must be set.")
        if focused {
            if !uiControl.isFirstResponder {
                return uiControl.becomeFirstResponder()
            }
        } else if uiControl.isFirstResponder {
            return uiControl.resignFirstResponder()
        }
        return false
    }

    // MARK: - Private Properties

    private weak var uiControl: UIControl?
}

extension FocusableViewProxy: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.isFocused == rhs.isFocused
    }
}

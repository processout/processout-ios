//
//  KeyboardNotification.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.05.2023.
//

import UIKit

struct KeyboardNotification {

    /// Keyboard’s frame at the end of its animation.
    let frameEnd: CGRect

    /// Animation duration.
    let animationDuration: TimeInterval?

    /// Animation curve that the system uses to animate the keyboard onto or off the screen.
    let animationCurve: UIView.AnimationCurve?

    /// Extracts keyboard information from given notification.
    init?(notification: Notification) {
        guard let frameEnd = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return nil
        }
        self.frameEnd = frameEnd
        animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        let rawCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int
        animationCurve = rawCurve.flatMap(UIView.AnimationCurve.init)
    }
}

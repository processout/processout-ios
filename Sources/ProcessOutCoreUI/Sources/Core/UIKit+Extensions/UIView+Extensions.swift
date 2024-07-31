//
//  UIView+Extensions.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 05.12.2022.
//

import UIKit

extension UIView {

    /// If `withAnimation` is set to `true` runs given actions inside UIKit animation block otherwise performs
    /// without animation.
    static func perform(withAnimation animated: Bool, duration: TimeInterval, actions: @escaping () -> Void) {
        if animated {
            UIView.animate(withDuration: duration, animations: actions)
        } else {
            UIView.performWithoutAnimation(actions)
        }
    }
}

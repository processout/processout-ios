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

    /// Setting the value of this property to true hides the receiver and setting it to false shows
    /// the receiver. The default value is false.
    ///
    /// - Warning: UIKit has a known bug when changing `isHidden` on a subview of
    /// UIStackView does not always work. It seems to be caused by fact that `isHidden`
    /// is cumulative in `UIStackView`, so we have to ensure to not set it the same value
    /// twice http://www.openradar.me/25087688
    func setHidden(_ isHidden: Bool) {
        if isHidden != self.isHidden {
            self.isHidden = isHidden
        }
    }

    /// Adds transition animation to receiver's layer. Method must be called inside animation block
    /// to make sure that timing properties are properly set.
    func addTransitionAnimation(type: CATransitionType = .fade, subtype: CATransitionSubtype? = nil) {
        let transition = CATransition()
        transition.type = type
        transition.subtype = subtype
        if let animation = layer.action(forKey: "backgroundColor") as? CAAnimation {
            transition.duration = animation.duration
            transition.timingFunction = animation.timingFunction
        } else {
            return
        }
        layer.add(transition, forKey: "transition")
    }
}

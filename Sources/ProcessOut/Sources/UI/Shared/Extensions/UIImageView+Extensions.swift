//
//  UIImageView+Extensions.swift
//  
//
//  Created by Andrii Vysotskyi on 19.12.2022.
//

import UIKit

extension UIImageView {

    func setAspectRatio(_ ratio: CGFloat? = nil) {
        widthConstraint?.isActive = false
        guard let ratio else {
            return
        }
        let constraint = widthAnchor.constraint(equalTo: heightAnchor, multiplier: ratio)
        widthConstraint = constraint
        constraint.isActive = true
    }

    // MARK: - Private Nested Types

    private enum AssociatedKeys {
        static var widthConstraint: UInt8 = 0
    }

    // MARK: - Private Properties

    private var widthConstraint: NSLayoutConstraint? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.widthConstraint) as? NSLayoutConstraint }
        set { objc_setAssociatedObject(self, &AssociatedKeys.widthConstraint, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
}

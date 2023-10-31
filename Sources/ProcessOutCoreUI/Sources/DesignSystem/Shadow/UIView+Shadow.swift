//
//  UIView+Shadow.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.10.2023.
//

import UIKit

extension UIView {

    /// Applies given shadow style to view's layer.
    @available(iOS 14, *)
    func apply(style: POShadowStyle, shadowOpacity: CGFloat = 1) {
        layer.shadowColor = style.color.cgColor
        layer.shadowOpacity = Float(shadowOpacity)
        layer.shadowOffset = style.offset
        layer.shadowRadius = style.radius
    }
}

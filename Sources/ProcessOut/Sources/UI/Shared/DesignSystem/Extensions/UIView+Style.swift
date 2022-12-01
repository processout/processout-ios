//
//  UIView+Style.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 28.11.2022.
//

import UIKit

extension UIView {

    /// Applies given border style to view's layer.
    func apply(style: POBorderStyle) {
        layer.cornerRadius = style.radius
        layer.borderWidth = style.width
        layer.borderColor = style.color.cgColor
    }

    /// Applies given shadow style to view's layer.
    func apply(style: POShadowStyle) {
        layer.shadowColor = style.color.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = style.offset
        layer.shadowRadius = style.radius
    }
}

//
//  UIView+Border.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.10.2023.
//

import UIKit

extension UIView {

    /// Applies given border style to view's layer.
    @available(iOS 14, *)
    func apply(style: POBorderStyle) {
        layer.cornerRadius = style.radius
        layer.borderWidth = style.width
        layer.borderColor = style.color.cgColor
    }
}

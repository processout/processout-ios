//
//  UIActivityIndicatorView+Extensions.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 28.11.2022.
//

import UIKit

extension UIActivityIndicatorView: POActivityIndicatorView {

    public func setAnimating(_ isAnimating: Bool) {
        if isAnimating {
            startAnimating()
        } else {
            stopAnimating()
        }
    }
}

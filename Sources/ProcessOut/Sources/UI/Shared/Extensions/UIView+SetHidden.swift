//
//  UIView+SetHidden.swift
//  
//
//  Created by Andrii Vysotskyi on 05.12.2022.
//

import UIKit

extension UIView {

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
}

//
//  UIView+InputIdentifier.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 05.10.2023.
//

import UIKit

extension UIView {

    var inputIdentifier: String? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.inputIdentifier) as? String }
        set { objc_setAssociatedObject(self, &AssociatedKeys.inputIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }

    // MARK: - Private Nested Types

    private enum AssociatedKeys {
        static var inputIdentifier: UInt8 = 0
    }
}

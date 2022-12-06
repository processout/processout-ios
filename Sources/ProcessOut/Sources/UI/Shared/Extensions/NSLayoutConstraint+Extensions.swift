//
//  NSLayoutConstraint+Extensions.swift
//  
//
//  Created by Andrii Vysotskyi on 05.12.2022.
//

import UIKit

extension NSLayoutConstraint {

    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

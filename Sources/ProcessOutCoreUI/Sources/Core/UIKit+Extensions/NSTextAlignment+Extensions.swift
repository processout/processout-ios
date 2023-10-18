//
//  NSTextAlignment+Extensions.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 22.09.2023.
//

import UIKit
import SwiftUI

extension NSTextAlignment {

    init(_ alignment: TextAlignment) {
        switch alignment {
        case .center:
            self = .center
        case .leading:
            self = .left
        case .trailing:
            self = .right
        }
    }
}

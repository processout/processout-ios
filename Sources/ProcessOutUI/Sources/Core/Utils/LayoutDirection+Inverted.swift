//
//  LayoutDirection+Inverted.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 22.03.2024.
//

import SwiftUI

extension LayoutDirection {

    /// Returns inverted layout direction.
    var inverted: LayoutDirection {
        self == .leftToRight ? .rightToLeft : .leftToRight
    }
}

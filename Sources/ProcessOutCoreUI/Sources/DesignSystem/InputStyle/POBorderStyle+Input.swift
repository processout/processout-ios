//
//  POBorderStyle+Input.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.01.2025.
//

import SwiftUI

extension POBorderStyle {

    /// Creates border style with given color that should be used with inputs.
    static func input(color: Color, wide: Bool = false) -> POBorderStyle {
        .init(radius: 6, width: wide ? 2.0 : 1.5, color: color)
    }
}

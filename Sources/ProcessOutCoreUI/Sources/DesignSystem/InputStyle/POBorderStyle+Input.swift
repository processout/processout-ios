//
//  POBorderStyle+Input.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.01.2025.
//

import SwiftUI

extension POBorderStyle {

    /// Creates border style with given color that should be used with inputs.
    static func input(color: Color) -> POBorderStyle {
        .init(radius: 6, width: 1.5, color: color)
    }
}

//
//  POBorderStyle+RadioButton.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.01.2025.
//

import SwiftUI

extension POBorderStyle {

    /// Creates border style with given color that should be used with radio buttons.
    static func radioButton(color: Color = .clear) -> POBorderStyle {
        .init(radius: 0, width: 1, color: color)
    }
}

//
//  POBorderRadius+Toast.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.01.2025.
//

import SwiftUI

extension POBorderStyle {

    /// Creates border style with given color that should be used with buttons.
    static func toast(color: Color) -> POBorderStyle {
        .init(radius: 8, width: 1, color: color)
    }
}

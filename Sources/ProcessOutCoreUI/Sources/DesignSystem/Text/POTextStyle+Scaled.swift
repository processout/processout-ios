//
//  POTextStyle+Scaled.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.01.2025.
//

import Foundation

extension POTextStyle {

    /// Auxiliary method that returns same text style with given scale applied to its typography.
    func scaledBy(_ scale: CGFloat) -> POTextStyle {
        .init(color: color, typography: typography.scaledBy(scale))
    }
}

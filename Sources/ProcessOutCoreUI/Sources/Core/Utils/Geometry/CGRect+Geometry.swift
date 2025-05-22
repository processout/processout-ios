//
//  CGRect+Geometry.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.04.2025.
//

import CoreGraphics

extension CGRect {

    /// Returns the center point of the rectangle.
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

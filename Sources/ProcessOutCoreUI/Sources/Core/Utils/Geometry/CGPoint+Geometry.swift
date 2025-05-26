//
//  CGPoint+Geometry.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.04.2025.
//

import CoreGraphics

extension CGPoint {

    /// Adds a vector to a point, effectively shifting the point to a new location by the vector's components.
    static func + (point: CGPoint, vector: CGVector) -> CGPoint {
        CGPoint(x: point.x + vector.dx, y: point.y + vector.dy)
    }
}

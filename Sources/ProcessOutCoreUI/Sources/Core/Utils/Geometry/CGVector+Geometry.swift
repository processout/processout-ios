//
//  CGVector+Geometry.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.04.2025.
//

import CoreGraphics

extension CGVector {

    /// Computes the vector's length
    var length: CGFloat {
        sqrt(dx * dx + dy * dy)
    }

    /// Returns the unit vector, which is a vector in the same direction with length 1, or `nil` if the length is zero.
    var unit: CGVector? {
        let length = self.length
        guard length > 0 else {
            return nil
        }
        return .init(dx: dx / length, dy: dy / length)
    }
}

/// Scales the vector by a given factor, changing its magnitude while keeping its direction.
func * (vector: CGVector, scale: CGFloat) -> CGVector {
    CGVector(dx: vector.dx * scale, dy: vector.dy * scale)
}

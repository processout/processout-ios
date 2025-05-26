//
//  GeometryUtils.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.04.2025.
//

import CoreGraphics

enum Geometry {

    /// Returns point on the circle at the specified radius in the direction of the end point.
    static func radialProjection(center: CGPoint, radius: CGFloat, towards end: CGPoint) -> CGPoint {
        let direction = CGVector(dx: end.x - center.x, dy: end.y - center.y)
        guard let unitDirection = direction.unit else {
            return center // Start and end point are the same
        }
        return center + unitDirection * radius
    }

    /// Returns the radius of a circle that can be circumscribed around the given rectangle.
    static func circleRadius(circumscribedAround rect: CGRect) -> CGFloat {
        sqrt(rect.width * rect.width + rect.height * rect.height) / 2
    }
}

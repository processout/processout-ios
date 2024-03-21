//
//  TrimmedRoundedRectangle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 21.03.2024.
//

import SwiftUI

@_spi(PO)
public struct POTrimmedRoundedRectangle: Shape {

    /// Creates shape instance.
    ///
    /// - Parameters:
    ///   - cornerRadius: The width and height of the rounded corners.
    ///   - gapWidth: Gap width to add to path on top edge.
    public init(cornerRadius: CGFloat = POSpacing.small, gapWidth: CGFloat) {
        self.cornerRadius = cornerRadius
        self.gapWidth = gapWidth
    }

    // MARK: - Shape

    // swiftlint:disable:next function_body_length
    public func path(in rect: CGRect) -> Path {
        let adjustedCornerRadius = min(
            min(rect.width, rect.height) / 2, cornerRadius
        )
        let adjustedGapWidth = min(rect.width - adjustedCornerRadius * 2, gapWidth)
        var path = Path()
        path.move(
            to: CGPoint(x: rect.midX + adjustedGapWidth / 2, y: rect.minY)
        )
        path.addLine(
            to: CGPoint(x: rect.maxX - adjustedCornerRadius, y: rect.minY)
        )
        path.addArc(
            center: CGPoint(x: rect.maxX - adjustedCornerRadius, y: rect.minY + adjustedCornerRadius),
            radius: adjustedCornerRadius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(
            to: CGPoint(x: rect.maxX, y: rect.maxY - adjustedCornerRadius)
        )
        path.addArc(
            center: CGPoint(x: rect.maxX - adjustedCornerRadius, y: rect.maxY - adjustedCornerRadius),
            radius: adjustedCornerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        path.addLine(
            to: CGPoint(x: rect.minX + adjustedCornerRadius, y: rect.maxY)
        )
        path.addArc(
            center: CGPoint(x: rect.minX + adjustedCornerRadius, y: rect.maxY - adjustedCornerRadius),
            radius: adjustedCornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.addLine(
            to: CGPoint(x: rect.minX, y: rect.minY + adjustedCornerRadius)
        )
        path.addArc(
            center: CGPoint(x: rect.minX + adjustedCornerRadius, y: rect.minY + adjustedCornerRadius),
            radius: adjustedCornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.addLine(
            to: CGPoint(x: rect.midX - adjustedGapWidth / 2, y: rect.minY)
        )
        return path
    }

    // MARK: - Private Properties

    private let cornerRadius, gapWidth: CGFloat
}

//
//  CheckboxToggleCheckmarkView.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 29.07.2024.
//

import SwiftUI

@available(iOS 14, *)
@MainActor
struct CheckboxToggleCheckmarkView: View {

    init(style: POCheckboxToggleStateStyle.Checkmark, textStyle: UIFont.TextStyle?) {
        self.style = style
        self._sizeScale = .init(wrappedValue: 1, relativeTo: textStyle)
    }

    // MARK: - View

    var body: some View {
        CheckmarkShape()
            .trim(from: 0, to: isSelected ? 1.0 : 0)
            .stroke(
                style.color,
                style: StrokeStyle(lineWidth: style.width * sizeScale, lineCap: .round, lineJoin: .round)
            )
            .frame(width: Constants.checkmarkSize * sizeScale, height: Constants.checkmarkSize * sizeScale)
            .frame(width: Constants.size * sizeScale, height: Constants.size * sizeScale)
            .background(style.backgroundColor)
            .border(style: style.border)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let size: CGFloat = 16
        static let checkmarkSize = Constants.size * 0.75
    }

    // MARK: - Private Properties

    private let style: POCheckboxToggleStateStyle.Checkmark

    @Environment(\.poControlSelected)
    private var isSelected: Bool

    @POBackport.ScaledMetric
    private var sizeScale: CGFloat
}

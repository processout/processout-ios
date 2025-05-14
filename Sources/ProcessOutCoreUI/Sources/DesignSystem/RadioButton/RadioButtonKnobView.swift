//
//  RadioButtonKnobView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.01.2025.
//

import SwiftUI

@available(iOS 14, *)
struct RadioButtonKnobView: View {

    init(style: PORadioButtonKnobStateStyle, textStyle: UIFont.TextStyle?) {
        self.style = style
        self._sizeScale = .init(wrappedValue: 1, relativeTo: textStyle)
    }

    // MARK: - View

    var body: some View {
        ZStack {
            Circle()
                .fill(style.backgroundColor)
            Circle()
                .strokeBorder(style.border.color, lineWidth: style.border.width)
            Circle()
                .fill(style.innerCircleColor)
                .frame(width: isSelected ? style.innerCircleRadius * 2 * sizeScale : 0)
        }
        .frame(width: Constants.size * sizeScale, height: Constants.size * sizeScale)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let size: CGFloat = 16
    }

    // MARK: - Private Properties

    private let style: PORadioButtonKnobStateStyle

    @Environment(\.poControlSelected)
    private var isSelected: Bool

    @POBackport.ScaledMetric
    private var sizeScale: CGFloat
}

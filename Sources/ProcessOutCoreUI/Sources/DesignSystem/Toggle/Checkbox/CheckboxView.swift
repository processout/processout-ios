//
//  CheckboxView.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 29.07.2024.
//

import SwiftUI

@MainActor
struct CheckboxView: View {

    /// Determines whether the checkbox is selected or not.
    let isSelected: Bool

    /// Resolved style.
    let style: POCheckboxToggleStateStyle.Checkmark

    // MARK: - View

    var body: some View {
        CheckmarkShape()
            .trim(from: 0, to: isSelected ? 1.0 : 0)
            .stroke(
                style.color,
                style: StrokeStyle(lineWidth: style.width, lineCap: .round, lineJoin: .round)
            )
            .frame(width: Constants.checkmarkSize, height: Constants.checkmarkSize)
            .frame(width: Constants.size, height: Constants.size)
            .background(style.backgroundColor)
            .border(style: style.border)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let size: CGFloat = 22
        static let checkmarkSize = Constants.size * 0.75
    }
}

//
//  ConstrainedRectangle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 30.07.2024.
//

import SwiftUI

/// A rectangular shape that automatically adjusts its size and position to
/// satisfy minimum size requirement.
struct ConstrainedRectangle: Shape {

    let minSize: CGSize

    // MARK: - Shape

    func path(in rect: CGRect) -> Path {
        let adjustedRect = rect.insetBy(
            dx: min(rect.width - minSize.width, 0) / 2, dy: min(rect.height - minSize.height, 0) / 2
        )
        return Path(roundedRect: adjustedRect, cornerSize: .zero)
    }
}

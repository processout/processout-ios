//
//  CheckmarkShape.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 29.07.2024.
//

// swiftlint:disable no_space_in_method_call

import SwiftUI

struct CheckmarkShape: Shape {

    func path(in rect: CGRect) -> Path {
        assert(abs(rect.width - rect.height) < 0.1, "Checkmark canvas is expected to be square.")
        let size = min(rect.width, rect.height)
        var path = Path()
        path.move   (to: CGPoint(x: 0.1565 * size, y: 0.5625 * size))
        path.addLine(to: CGPoint(x: 0.3750 * size, y: 0.7817 * size))
        path.addLine(to: CGPoint(x: 0.8750 * size, y: 0.2815 * size))
        return path
    }

    @available(iOS 17.0, *)
    var layoutDirectionBehavior: LayoutDirectionBehavior {
        .fixed
    }
}

// swiftlint:enable no_space_in_method_call

//
//  View+Scale.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.06.2025.
//

import SwiftUI

extension View {

    @ViewBuilder
    func scale(_ scale: CGFloat) -> some View {
        if #available(iOS 16.0, *) {
            ScalingLayout(scale: scale) {
                _UnaryViewAdaptor(scaleEffect(scale, anchor: .center))
            }
        } else {
            scaleEffect(scale, anchor: .center)
        }
    }
}

@available(iOS 16.0, *)
private struct ScalingLayout: Layout {

    let scale: CGFloat

    // MARK: - Layout

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let size = subviews[0].sizeThatFits(proposal)
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        return CGRect(origin: .zero, size: size).applying(transform).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews[0].place(at: .init(x: bounds.midX, y: bounds.midY), anchor: .center, proposal: proposal)
    }
}

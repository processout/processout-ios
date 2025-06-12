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
            modifier(ScalingLayoutModifier(scale: scale))
        } else {
            modifier(ScalingModifier(scale: scale))
        }
    }
}

@available(iOS 16.0, *)
private struct ScalingLayoutModifier: ViewModifier {

    let scale: CGFloat

    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        ScalingLayout(scale: scale) {
            _UnaryViewAdaptor(content.scaleEffect(scale, anchor: .center))
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

@available(iOS, obsoleted: 16, message: "Use `ScalingLayoutModifier` instead.")
private struct ScalingModifier: ViewModifier {

    let scale: CGFloat

    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        _UnaryViewAdaptor(content)
            .onSizeChange { size in
                contentSize = size
            }
            .scaleEffect(scale, anchor: .center)
            .padding(
                contentPadding
            )
    }

    // MARK: - Private Properties

    @State
    private var contentSize: CGSize?

    // MARK: - Private Methods

    private var contentPadding: EdgeInsets {
        guard let size = contentSize else {
            return .init(horizontal: 0, vertical: 0)
        }
        return EdgeInsets(
            horizontal: (size.width * scale - size.width) / 2,
            vertical: (size.height * scale - size.height) / 2
        )
    }
}

@available(iOS 17, *)
#Preview {
    Text("Preview")
        .scale(0.5)
        .background(Color.gray)
}

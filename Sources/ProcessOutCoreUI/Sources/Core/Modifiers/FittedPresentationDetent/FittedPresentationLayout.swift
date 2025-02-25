//
//  FittedPresentationLayout.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.02.2025.
//

import SwiftUI

@available(iOS 16.0, *)
struct FittedPresentationLayout: Layout {

    func makeCache(subviews: Subviews) -> Cache {
        Cache()
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        precondition(subviews.count == 2, "Expected exactly two subviews.")
        let idealContentSize = idealContentSize(
            proposal: proposal, subviews: subviews, cache: &cache
        )
        return .init(width: idealContentSize.width, height: proposal.height ?? idealContentSize.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        precondition(subviews.count == 2, "Expected exactly two subviews.")
        let idealContentSize = idealContentSize(
            proposal: proposal, subviews: subviews, cache: &cache
        )
        let sizingView = subviews[0], contentView = subviews[1]
        sizingView.place(
            at: bounds.origin, proposal: .init(idealContentSize)
        )
        let contentHeight = min(idealContentSize.height, bounds.height)
        contentView.place(at: bounds.origin, proposal: .init(width: idealContentSize.width, height: contentHeight))
    }

    // MARK: - Nested Types

    struct Cache {

        /// Ideal content size.
        var idealContentSize: [AnyHashable: CGSize] = [:]
    }

    // MARK: - Private Properties

    private func idealContentSize(
        proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache
    ) -> CGSize {
        let cacheKey = self.cacheKey(for: proposal)
        if let idealSize = cache.idealContentSize[cacheKey] {
            return idealSize
        }
        let contentView = subviews[1]
        let idealSize = contentView.sizeThatFits(.init(width: proposal.width, height: nil))
        cache.idealContentSize[cacheKey] = idealSize
        return idealSize
    }

    private func cacheKey(for proposal: ProposedViewSize) -> AnyHashable {
        guard let width = proposal.width else {
            return AnyHashable(nil as Int?)
        }
        guard !width.isInfinite else {
            return width > 0 ? Int.max : Int.min
        }
        guard !width.isNaN else {
            preconditionFailure("Proposal contains invalid dimension(s).")
        }
        // Use fixed-point representation to avoid hashing issues
        let scale: CGFloat = 100
        return Int((width * Double(scale)).rounded())
    }
}

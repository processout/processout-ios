//
//  CollectionReusableViewSizeProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2023.
//

import UIKit

@MainActor
final class CollectionReusableViewSizeProvider {

    init() {
        templateViews = [:]
    }

    func systemLayoutSize<View: UICollectionReusableView>(
        viewType: View.Type, preferredWidth: CGFloat, configure: ((View) -> Void)? = nil
    ) -> CGSize {
        let view = view(viewType)
        view.prepareForReuse()
        configure?(view)
        view.frame.size.width = preferredWidth
        view.setNeedsLayout()
        view.layoutIfNeeded()
        var contentView: UIView = view
        if let cell = view as? UICollectionViewCell {
            contentView = cell.contentView
        }
        let targetSize = CGSize(width: preferredWidth, height: UIView.layoutFittingCompressedSize.height)
        let size = contentView.systemLayoutSizeFitting(
            targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel
        )
        return CGSize(width: preferredWidth, height: size.height)
    }

    // MARK: - Private Properties

    private var templateViews: [ObjectIdentifier: UICollectionReusableView]

    // MARK: - Private Methods

    private func view<View: UICollectionReusableView>(_ viewType: View.Type) -> View {
        let identifier = ObjectIdentifier(viewType)
        if let view = templateViews[identifier] as? View {
            return view
        }
        let view = View()
        templateViews[identifier] = view
        return view
    }
}

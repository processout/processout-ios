//
//  BetaNativeAlternativePaymentMethodCollectionLayout.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 26.04.2023.
//

import UIKit

// swiftlint:disable:next type_name
protocol BetaNativeAlternativePaymentMethodCollectionLayoutDelegate: AnyObject, UICollectionViewDelegateFlowLayout {

    /// Should return index of the section that should be centered.
    func centeredSection(
        in collectionView: UICollectionView, layout: BetaNativeAlternativePaymentMethodCollectionLayout
    ) -> Int?
}

final class BetaNativeAlternativePaymentMethodCollectionLayout: UICollectionViewFlowLayout {

    override func invalidateLayout() {
        super.invalidateLayout()
        centeredSection = nil
        centeringOffset = 0
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        centeredSection = nil
        centeringOffset = 0
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        collectionView?.bounds.size != newBounds.size || super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }

    override func prepare() {
        super.prepare()
        contentSize = super.collectionViewContentSize
        guard let collectionView, let section = delegate.centeredSection(in: collectionView, layout: self) else {
            return
        }
        let updatedHeight = collectionView.bounds.inset(by: collectionView.adjustedContentInset).height
        let offset = (updatedHeight - contentSize.height) / 2
        guard offset > 0 else {
            return
        }
        centeredSection = section
        centeringOffset = offset
        contentSize.height = updatedHeight
    }

    override var collectionViewContentSize: CGSize {
        contentSize
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        super.layoutAttributesForItem(at: indexPath).flatMap(centered(attributes:))
    }

    override func layoutAttributesForSupplementaryView(
        ofKind elementKind: String, at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath).flatMap(centered(attributes:))
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        super.layoutAttributesForElements(in: rect)?.compactMap(centered(attributes:))
    }

    // MARK: - Private Properties

    private var centeredSection: Int?
    private var centeringOffset: CGFloat = 0
    private var contentSize: CGSize = .zero

    private var delegate: BetaNativeAlternativePaymentMethodCollectionLayoutDelegate {
        // swiftlint:disable:next force_cast force_unwrapping
        collectionView!.delegate as! BetaNativeAlternativePaymentMethodCollectionLayoutDelegate
    }

    // MARK: - Centered Items

    private func centered(attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes? {
        switch attributes.representedElementCategory {
        case .cell, .supplementaryView:
            break
        default:
            return attributes
        }
        guard let centeredSection, attributes.indexPath.section >= centeredSection else {
            return attributes
        }
        let attributesCopy = attributes.copy() as? UICollectionViewLayoutAttributes
        attributesCopy?.frame.origin.y += centeringOffset
        return attributesCopy
    }
}

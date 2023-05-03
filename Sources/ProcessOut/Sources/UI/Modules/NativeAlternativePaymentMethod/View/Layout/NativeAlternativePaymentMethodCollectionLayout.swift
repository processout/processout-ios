//
//  NativeAlternativePaymentMethodCollectionLayout.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 26.04.2023.
//

import UIKit

final class NativeAlternativePaymentMethodCollectionLayout: UICollectionViewFlowLayout {

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
        prepareCentering()
    }

    override var collectionViewContentSize: CGSize {
        var size = super.collectionViewContentSize
        size.height += 2 * centeringOffset
        return size
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        super.layoutAttributesForItem(at: indexPath).flatMap(centered)
    }

    override func layoutAttributesForSupplementaryView(
        ofKind elementKind: String, at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath).flatMap(centered)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        super.layoutAttributesForElements(in: rect)?.compactMap(centered)
    }

    // MARK: - Private Properties

    private var centeredSection: Int?
    private var centeringOffset: CGFloat = 0

    private var delegate: NativeAlternativePaymentMethodCollectionLayoutDelegate {
        // swiftlint:disable:next force_cast force_unwrapping
        collectionView!.delegate as! NativeAlternativePaymentMethodCollectionLayoutDelegate
    }

    // MARK: - Centered Items

    private func prepareCentering() {
        guard centeredSection == nil else {
            return
        }
        guard let collectionView, let section = delegate.centeredSection(in: collectionView, layout: self) else {
            return
        }
        let updatedHeight = collectionView.bounds.inset(by: collectionView.adjustedContentInset).height
        let offset = (updatedHeight - super.collectionViewContentSize.height) / 2
        guard offset > 0 else {
            return
        }
        centeredSection = section
        centeringOffset = offset
    }

    private func centered(attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes? {
        switch attributes.representedElementCategory {
        case .cell, .supplementaryView:
            break
        default:
            return attributes
        }
        guard let centeredSection,
              attributes.indexPath.section >= centeredSection,
              let attributesCopy = attributes.copy() as? UICollectionViewLayoutAttributes else {
            return attributes
        }
        attributesCopy.frame.origin.y += centeringOffset
        return attributesCopy
    }
}

//
//  NativeAlternativePaymentMethodCollectionLayout.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 26.04.2023.
//

import UIKit

final class NativeAlternativePaymentMethodCollectionLayout: UICollectionViewFlowLayout {

    override init() {
        centeringOffset = 0
        layoutAttributes = [:]
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var sectionHeadersPinToVisibleBounds: Bool {
        didSet { assert(!sectionHeadersPinToVisibleBounds) }
    }

    override var sectionFootersPinToVisibleBounds: Bool {
        didSet { assert(!sectionFootersPinToVisibleBounds) }
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        centeredSection = nil
        centeringOffset = 0
        layoutAttributes = [:]
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let isWidthDifferent = abs(collectionView().bounds.width - newBounds.width) > 0.001
        return isWidthDifferent || super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }

    override func prepare() {
        super.prepare()
        prepareCentering()
        prepareSectionBackgroundAttributes()
    }

    override var collectionViewContentSize: CGSize {
        // This is a workaround for `layoutAttributesForElementsInRect:` not getting invoked enough
        // times if `collectionViewContentSize.width` is not smaller than the width of the collection
        // view, minus horizontal insets.
        // See https://openradar.appspot.com/radar?id=5025850143539200 for more details.
        let width = collectionView().bounds.inset(by: collectionView().adjustedContentInset).width - 0.0001
        return CGSize(width: width, height: super.collectionViewContentSize.height + centeringOffset)
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // There are no custom item attributes so we are simply centering attributes returned by super.
        super.layoutAttributesForItem(at: indexPath).flatMap(centered)
    }

    override func layoutAttributesForSupplementaryView(
        ofKind kind: String, at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        let key = LayoutAttributesKey(indexPath: indexPath, category: .supplementaryView, kind: kind)
        if let attributes = layoutAttributes[key] {
            return attributes
        }
        return super.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath).flatMap(centered)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Original rect's origin is shifted by negative centeringOffset and height is increased by same value
        // to ensure that super will also return attributes visible after centering.
        let centeringAdjustedRect = CGRect(
            x: rect.minX,
            y: rect.minY - centeringOffset,
            width: rect.width,
            height: rect.height + centeringOffset
        )
        var attributes = super.layoutAttributesForElements(in: centeringAdjustedRect)?.compactMap(centered) ?? []
        let visibleLayoutAttributes = layoutAttributes.values.filter { attributes in
            // Here we are using original rect because attributes are already centered.
            attributes.frame.intersects(rect)
        }
        attributes.append(contentsOf: visibleLayoutAttributes)
        return attributes
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let additionalSectionBackgroundBottomOffset: CGFloat = 160
    }

    private struct LayoutAttributesKey: Hashable {

        /// Index path.
        let indexPath: IndexPath

        /// Attributes category.
        let category: UICollectionView.ElementCategory

        /// Kind.
        let kind: String?
    }

    // MARK: - Private Properties

    private var centeredSection: Int?
    private var centeringOffset: CGFloat
    private var layoutAttributes: [LayoutAttributesKey: UICollectionViewLayoutAttributes]

    // MARK: -

    private func delegate() -> NativeAlternativePaymentMethodCollectionLayoutDelegate {
        // swiftlint:disable:next force_cast force_unwrapping
        return collectionView!.delegate as! NativeAlternativePaymentMethodCollectionLayoutDelegate
    }

    private func collectionView() -> UICollectionView {
        collectionView! // swiftlint:disable:this force_unwrapping
    }

    // MARK: - Centering

    private func prepareCentering() {
        guard let section = delegate().centeredSection(layout: self) else {
            return
        }
        let updatedHeight = collectionView().bounds.inset(by: collectionView().adjustedContentInset).height
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
            // Decorations are not centered.
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

    // MARK: - Section Background

    private func prepareSectionBackgroundAttributes() {
        let numberOfSections = collectionView().numberOfSections
        guard numberOfSections != 0 else {
            return
        }
        // swiftlint:disable:next line_length
        for section in 0 ..< numberOfSections where delegate().collectionViewLayout(self, shouldDecorateSectionAt: section) {
            let numberOfItemsInSection = collectionView().numberOfItems(inSection: section)
            guard numberOfItemsInSection > 0 else {
                assertionFailure("Attempted to decorate empty section which is not supported.")
                continue
            }
            let lastItemIndexPath = IndexPath(row: numberOfItemsInSection - 1, section: section)
            guard let lastItemAttributes = layoutAttributesForItem(at: lastItemIndexPath) else {
                assertionFailure("Can't find attributes for last item in section.")
                continue
            }
            let height = lastItemAttributes.frame.maxY
                + collectionView().adjustedContentInset.top
                + Constants.additionalSectionBackgroundBottomOffset
            prepareSectionBackgroundAttributes(at: section, height: height)
        }
    }

    private func prepareSectionBackgroundAttributes(at index: Int, height: CGFloat) {
        let attributes = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: Self.elementKindSectionBackground, with: IndexPath(row: 0, section: index)
        )
        attributes.frame = CGRect(
            x: -collectionView().adjustedContentInset.left,
            y: -collectionView().adjustedContentInset.top,
            width: collectionView().bounds.width,
            height: height
        )
        attributes.zIndex = -1
        let layoutAttributesKey = LayoutAttributesKey(
            indexPath: attributes.indexPath,
            category: attributes.representedElementCategory,
            kind: attributes.representedElementKind
        )
        layoutAttributes[layoutAttributesKey] = attributes
    }
}

extension NativeAlternativePaymentMethodCollectionLayout {

    /// Section background element kind.
    static let elementKindSectionBackground = "ElementKindSectionBackground"
}

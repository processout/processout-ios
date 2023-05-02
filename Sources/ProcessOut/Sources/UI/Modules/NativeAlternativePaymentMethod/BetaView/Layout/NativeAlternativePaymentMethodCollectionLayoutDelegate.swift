//
//  NativeAlternativePaymentMethodCollectionLayoutDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 01.05.2023.
//

import UIKit

// swiftlint:disable:next type_name
protocol NativeAlternativePaymentMethodCollectionLayoutDelegate: AnyObject, UICollectionViewDelegateFlowLayout {

    /// Should return index of the section that should be centered.
    func centeredSection(
        in collectionView: UICollectionView, layout: NativeAlternativePaymentMethodCollectionLayout
    ) -> Int?

    func centeringInset() -> UIEdgeInsets

    // todo: add something to delegate to
}

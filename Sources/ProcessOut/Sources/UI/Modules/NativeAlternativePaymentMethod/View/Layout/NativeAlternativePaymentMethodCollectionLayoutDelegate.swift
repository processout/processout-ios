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
    func centeredSection(layout: UICollectionViewLayout) -> Int?

    /// Asks delegate whether section at given index should be decorated.
    func collectionViewLayout(_ layout: UICollectionViewLayout, shouldDecorateSectionAt index: Int) -> Bool
}

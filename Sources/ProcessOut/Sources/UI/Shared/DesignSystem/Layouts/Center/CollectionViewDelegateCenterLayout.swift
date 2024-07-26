//
//  CollectionViewDelegateCenterLayout.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 01.05.2023.
//

import UIKit

@MainActor
protocol CollectionViewDelegateCenterLayout: AnyObject, UICollectionViewDelegateFlowLayout {

    /// Should return index of the section that should be centered.
    func centeredSection(layout: UICollectionViewLayout) -> Int?

    /// Asks delegate whether cell at given index should be decorated with separator.
    func collectionViewLayout(_ layout: UICollectionViewLayout, shouldSeparateCellAt indexPath: IndexPath) -> Bool
}

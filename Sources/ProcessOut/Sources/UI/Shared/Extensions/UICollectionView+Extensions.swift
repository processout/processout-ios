//
//  UICollectionView+Extensions.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2023.
//

import UIKit

extension UICollectionView {

    func registerCell<Cell: UICollectionViewCell>(_ cellClass: Cell.Type) {
        register(cellClass, forCellWithReuseIdentifier: Cell.reuseIdentifier)
    }

    func dequeueReusableCell<Cell: UICollectionViewCell>(_ cellClass: Cell.Type, for indexPath: IndexPath) -> Cell {
        // swiftlint:disable:next force_cast
        dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }

    func registerSupplementaryView<View: UICollectionReusableView>(_ viewClass: View.Type, kind: String) {
        register(viewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: View.reuseIdentifier)
    }

    func dequeueReusableSupplementaryView<View: UICollectionReusableView>(
        _ viewClass: View.Type, kind: String, indexPath: IndexPath
    ) -> View {
        dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: View.reuseIdentifier, for: indexPath
        ) as! View // swiftlint:disable:this force_cast
    }
}

extension UICollectionReusableView: Reusable {

    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}

//
//  FeaturesFeatureCell.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

import UIKit

final class FeaturesFeatureCell: UICollectionViewListCell {

    typealias CellRegistration = UICollectionView.CellRegistration<FeaturesFeatureCell, FeaturesViewModelState.Feature>

    static let registration = CellRegistration { cell, _, model in
        var configuration = cell.defaultContentConfiguration()
        configuration.text = model.name
        cell.contentConfiguration = configuration
    }
}

//
//  AlternativePaymentMethodsConfigurationCell.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import UIKit

final class AlternativePaymentMethodsConfigurationCell: UICollectionViewListCell {

    typealias CellRegistration = UICollectionView.CellRegistration<
        AlternativePaymentMethodsFailureCell, AlternativePaymentMethodsViewModelState.ConfigurationItem
    >

    static let registration = CellRegistration { cell, _, model in
        var configuration = cell.defaultContentConfiguration()
        configuration.text = model.name
        cell.contentConfiguration = configuration
    }
}

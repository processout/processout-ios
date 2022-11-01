//
//  AlternativePaymentMethodsFailureCell.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import UIKit

final class AlternativePaymentMethodsFailureCell: UICollectionViewListCell {

    typealias CellRegistration = UICollectionView.CellRegistration<
        AlternativePaymentMethodsFailureCell, AlternativePaymentMethodsViewModelState.FailureItem
    >

    static let registration = CellRegistration { cell, _, model in
        var configuration = cell.defaultContentConfiguration()
        configuration.image = UIImage(systemName: "exclamationmark.octagon")?.withRenderingMode(.alwaysOriginal)
        configuration.text = model.description
        cell.contentConfiguration = configuration
    }
}

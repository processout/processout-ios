//
//  AlternativePaymentDataItemCell.swift
//  Example
//
//  Created by Andrii Vysotskyi on 25.01.2023.
//

import UIKit

final class AlternativePaymentDataItemCell: UICollectionViewListCell {

    typealias CellRegistration = UICollectionView.CellRegistration<
        AlternativePaymentDataItemCell, AlternativePaymentDataViewModelState.Item
    >

    static let registration = CellRegistration { cell, _, model in
        var configuration = cell.defaultContentConfiguration()
        configuration.text = model.title
        configuration.secondaryText = model.subtitle
        cell.contentConfiguration = configuration
    }
}

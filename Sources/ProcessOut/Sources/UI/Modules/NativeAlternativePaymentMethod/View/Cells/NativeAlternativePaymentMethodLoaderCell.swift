//
//  NativeAlternativePaymentMethodLoaderCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2023.
//

import UIKit

final class NativeAlternativePaymentMethodLoaderCell: UICollectionViewCell {

    /// Implementation ignores 2nd and all subsequent calls to this method.
    func initialize(style: POActivityIndicatorStyle?) {
        guard !isInitialized else {
            return
        }
        let activityIndicator = ActivityIndicatorViewFactory().create(style: style ?? Constants.defaultStyle)
        activityIndicator.hidesWhenStopped = false
        activityIndicator.setAnimating(true)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicator)
        let constraints = [
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        isInitialized = true
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let defaultStyle = POActivityIndicatorStyle.system(.whiteLarge)
    }

    // MARK: - Private Properties

    private var isInitialized = false
}

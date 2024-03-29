//
//  NativeAlternativePaymentMethodLoaderCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2023.
//

import UIKit

@available(*, deprecated)
final class NativeAlternativePaymentMethodLoaderCell: UICollectionViewCell {

    /// Implementation ignores 2nd and all subsequent calls to this method.
    func initialize(style: POActivityIndicatorStyle) {
        guard !isInitialized else {
            return
        }
        let activityIndicator = ActivityIndicatorViewFactory().create(style: style)
        activityIndicator.hidesWhenStopped = false
        activityIndicator.setAnimating(true)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicator)
        let constraints = [
            activityIndicator.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            activityIndicator.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        isInitialized = true
    }

    // MARK: - Private Properties

    private var isInitialized = false
}

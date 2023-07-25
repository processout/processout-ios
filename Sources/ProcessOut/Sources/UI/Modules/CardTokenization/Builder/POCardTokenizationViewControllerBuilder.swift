//
//  POCardTokenizationViewControllerBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.07.2023.
//

import UIKit

/// Provides an ability to create view controller that could be used to tokenize a card.
/// Call ``POCardTokenizationViewControllerBuilder/build()`` to
/// create view controller's instance.
@_spi(PO)
public final class POCardTokenizationViewControllerBuilder {

    /// Creates builder instance.
    public init() {
        style = POCardTokenizationStyle()
    }

    /// Sets UI style.
    public func with(style: POCardTokenizationStyle) -> Self {
        self.style = style
        return self
    }

    /// Completion to invoke when flow is completed.
    public func with(completion: @escaping (Result<POCard, POFailure>) -> Void) -> Self {
        self.completion = completion
        return self
    }

    /// Returns view controller that caller should encorporate into view controllers hierarchy.
    /// If instance can't be created assertion failure is triggered.
    ///
    /// - NOTE: Caller should dismiss view controller after completion is called.
    public func build() -> UIViewController {
        guard let completion else {
            preconditionFailure("Required parameters are not set.")
        }
        let api: ProcessOut = ProcessOut.shared // swiftlint:disable:this redundant_type_annotation
        let interactor = DefaultCardTokenizationInteractor(
            cardsService: api.cards,
            logger: api.logger,
            completion: completion
        )
        let viewModel = DefaultCardTokenizationViewModel(interactor: interactor)
        return CardTokenizationViewController(viewModel: viewModel, style: style, logger: api.logger)
    }

    // MARK: - Private Properties

    private var style: POCardTokenizationStyle
    private var completion: ((Result<POCard, POFailure>) -> Void)?
}

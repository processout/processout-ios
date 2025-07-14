//
//  POCardUpdateView+Init.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

@_spi(PO) import ProcessOut

extension POCardUpdateView {

    /// Creates card update view.
    ///
    /// - NOTE: Use caution when using this view, because SwiftUI only initializes
    /// its state once during the lifetime of the view — even if you call the initializer
    /// more than once — which might result in unexpected behavior.
    public init(
        configuration: POCardUpdateConfiguration,
        delegate: POCardUpdateDelegate? = nil,
        completion: @escaping (Result<POCard, POFailure>) -> Void
    ) {
        let viewModel = {
            var logger = ProcessOut.shared.logger
            logger[attributeKey: .cardId] = configuration.cardId
            let interactor = DefaultCardUpdateInteractor(
                cardsService: ProcessOut.shared.cards,
                logger: logger,
                configuration: configuration,
                delegate: delegate,
                completion: completion
            )
            return DefaultCardUpdateViewModel(interactor: interactor, configuration: configuration)
        }
        self = .init(viewModel: viewModel())
    }
}

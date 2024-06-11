//
//  POCardUpdateView+Init.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

@_spi(PO) import ProcessOut

@available(iOS 14, *)
extension POCardUpdateView {

    /// Creates card update view.
    public init(
        configuration: POCardUpdateConfiguration,
        delegate: POCardUpdateDelegate? = nil,
        completion: @escaping (Result<POCard, POFailure>) -> Void
    ) {
        var logger = ProcessOut.shared.logger
        logger[attributeKey: .cardId] = configuration.cardId
        let interactor = DefaultCardUpdateInteractor(
            cardsService: ProcessOut.shared.cards,
            logger: logger,
            configuration: configuration,
            delegate: delegate,
            completion: completion
        )
        let viewModel = DefaultCardUpdateViewModel(interactor: interactor, configuration: configuration)
        self = .init(viewModel: viewModel)
    }
}

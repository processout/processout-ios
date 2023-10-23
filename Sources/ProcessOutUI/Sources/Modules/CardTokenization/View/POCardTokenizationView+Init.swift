//
//  POCardTokenizationView+Init.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

extension POCardTokenizationView {

    /// Creates card tokenization view.
    /// - Parameters:
    ///   - completion: Completion to invoke when flow is completed.
    public init(
        configuration: POCardTokenizationConfiguration = .init(),
        delegate: POCardTokenizationDelegate? = nil,
        completion: @escaping (Result<POCard, POFailure>) -> Void
    ) {
        let viewModel = DefaultCardTokenizationViewModel(
            interactor: DefaultCardTokenizationInteractor(
                cardsService: ProcessOut.shared.cards,
                logger: ProcessOut.shared.logger,
                billingAddress: configuration.billingAddress,
                delegate: delegate,
                completion: completion
            ),
            configuration: configuration
        )
        self = .init(viewModel: viewModel)
    }
}

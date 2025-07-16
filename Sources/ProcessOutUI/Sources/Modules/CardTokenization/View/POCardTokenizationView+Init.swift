//
//  POCardTokenizationView+Init.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

@_spi(PO) import ProcessOut

extension POCardTokenizationView {

    /// Creates card tokenization view.
    ///
    /// - Parameters:
    ///   - completion: Completion to invoke when flow is completed.
    ///
    /// - NOTE: Use caution when using this view, because SwiftUI only initializes
    /// its state once during the lifetime of the view — even if you call the initializer
    /// more than once — which might result in unexpected behavior.
    public init(
        configuration: POCardTokenizationConfiguration = .init(),
        delegate: POCardTokenizationDelegate? = nil,
        completion: @escaping (Result<POCard, POFailure>) -> Void
    ) {
        let viewModel = {
            let interactor = DefaultCardTokenizationInteractor(
                cardsService: ProcessOut.shared.cards,
                logger: ProcessOut.shared.logger,
                configuration: configuration,
                completion: completion
            )
            interactor.delegate = delegate
            return DefaultCardTokenizationViewModel(interactor: interactor)
        }
        self = .init(viewModel: viewModel())
    }
}

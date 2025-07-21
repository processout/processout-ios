//
//  POCardTokenizationComponent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.07.2025.
//

@_spi(PO) import ProcessOut

/// A component responsible for managing the card tokenization, allowing external control.
@MainActor
public final class POCardTokenizationComponent {

    public init(
        configuration: POCardTokenizationConfiguration = .init(),
        delegate: POCardTokenizationDelegate? = nil,
        completion: @escaping (Result<POCard, POFailure>) -> Void
    ) {
        let interactor = DefaultCardTokenizationInteractor(
            cardsService: ProcessOut.shared.cards,
            logger: ProcessOut.shared.logger,
            configuration: configuration,
            completion: completion
        )
        interactor.delegate = delegate
        self.interactor = interactor
    }

    /// Starts the card tokenization process.
    public func tokenize() {
        interactor.tokenize()
    }

    /// Cancels the ongoing card tokenization process.
    public func cancel() {
        interactor.cancel()
    }

    // MARK: - Internal

    let interactor: any CardTokenizationInteractor
}

//
//  POCardTokenizationComponent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.07.2025.
//

@_spi(PO) import ProcessOut

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

    public func tokenize() {
        interactor.tokenize()
    }

    public func cancel() {
        interactor.cancel()
    }

    // MARK: - Internal

    let interactor: any CardTokenizationInteractor
}

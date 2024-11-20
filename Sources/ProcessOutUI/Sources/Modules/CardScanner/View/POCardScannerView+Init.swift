//
//  POCardScannerView+Init.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.11.2024.
//

@_spi(PO) import ProcessOut

@available(iOS 14, *)
extension POCardScannerView {

    /// Creates card scanner view.
    ///
    /// - NOTE: Use caution when using this view, because SwiftUI only initializes
    /// its state once during the lifetime of the view — even if you call the initializer
    /// more than once — which might result in unexpected behavior.
    public init(completion: @escaping (Result<POScannedCard, POFailure>) -> Void) {
        let viewModel = {
            let cardRecognitionSession = CardRecognitionSession(
                numberDetector: CardNumberDetector(
                    regexProvider: .shared, formatter: .init()
                ),
                expirationDetector: CardExpirationDetector(
                    regexProvider: .shared, formatter: .init()
                ),
                logger: ProcessOut.shared.logger
            )
            return DefaultCardScannerViewModel(
                cameraSession: .init(),
                cardRecognitionSession: cardRecognitionSession,
                completion: completion
            )
        }
        self = .init(viewModel: viewModel())
    }
}

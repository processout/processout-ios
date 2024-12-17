//
//  CardRecognitionSessionErrorCorrection.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.12.2024.
//

import Foundation
@_spi(PO) import ProcessOut

final class CardRecognitionSessionErrorCorrection {

    init(errorCorrectionDuration: TimeInterval = 3) {
        self.errorCorrectionDuration = errorCorrectionDuration
        numbers = [:]
        expirations = [:]
        names = [:]
    }

    /// Boolean value indicating whether error corrected card is confdent recognition.
    var isConfident: Bool {
        guard let startTime else {
            return false
        }
        let elapsedTime = DispatchTime.now().uptimeSeconds - startTime.uptimeSeconds
        return elapsedTime >= errorCorrectionDuration
    }

    func add(scannedCard: POScannedCard?) -> POScannedCard? {
        if isConfident {
            return errorCorrectedCard // Enough confidence is already reached, ignored.
        }
        if let scannedCard {
            startTime = startTime ?? DispatchTime.now()
            updateFrequencies(with: scannedCard)
            assert(errorCorrectedCard != nil, "Corrected card must be available after frequencies update.")
        }
        return errorCorrectedCard
    }

    // MARK: - Private Properties

    private let errorCorrectionDuration: TimeInterval
    private var numbers: [String: Int]
    private var expirations: [POScannedCard.Expiration: Int]
    private var names: [String: Int]
    private var startTime: DispatchTime?

    // MARK: - Private Methods

    private func updateFrequencies(with scannedCard: POScannedCard) {
        numbers[scannedCard.number, default: 0] += 1
        if let expiration = scannedCard.expiration {
            expirations[expiration, default: 0] += 1
        }
        if let cardholderName = scannedCard.cardholderName {
            names[cardholderName, default: 0] += 1
        }
    }

    private var errorCorrectedCard: POScannedCard? {
        let number = numbers.max { lhs, rhs in
            lhs.value < rhs.value
        }
        guard let number = number?.key else {
            return nil
        }
        let expiration = expirations.max { lhs, rhs in
            lhs.value < rhs.value
        }
        let name = names.max { lhs, rhs in
            lhs.value < rhs.value
        }
        return .init(number: number, expiration: expiration?.key, cardholderName: name?.key)
    }
}

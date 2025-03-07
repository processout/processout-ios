//
//  CardRecognitionSessionErrorCorrection.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.12.2024.
//

import Foundation
@_spi(PO) import ProcessOut

final class CardRecognitionSessionErrorCorrection {

    init(errorCorrectionDuration: TimeInterval = 3, shouldScanExpiredCard: Bool = false) {
        self.errorCorrectionDuration = errorCorrectionDuration
        self.shouldScanExpiredCard = shouldScanExpiredCard
        numbers = [:]
        expirations = [:]
        names = [:]
    }

    /// Boolean value indicating whether error corrected card is confident recognition.
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
            if let isExpired = scannedCard.expiration?.isExpired, isExpired, !shouldScanExpiredCard {
                invalidateFrequencies(with: scannedCard)
            } else {
                updateFrequencies(with: scannedCard)
            }
        }
        return errorCorrectedCard
    }

    // MARK: - Private Properties

    private let errorCorrectionDuration: TimeInterval
    private let shouldScanExpiredCard: Bool
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
        startTime = startTime ?? DispatchTime.now()
    }

    private func invalidateFrequencies(with expiredCard: POScannedCard) {
        numbers[expiredCard.number] = nil
        guard numbers.isEmpty else {
            return
        }
        names.removeAll()
        expirations.removeAll()
        startTime = nil
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

//
//  CardRecognitionSessionErrorCorrection.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.12.2024.
//

import Foundation

final class CardRecognitionSessionErrorCorrection {

    init() {
        isConfident = false
        numbers = [:]
        expirations = [:]
        names = [:]
    }

    /// Boolean value indicating whether error corrected card is confdent recognition.
    private(set) var isConfident: Bool

    var errorCorrectedCard: POScannedCard? {
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

    func add(scannedCard: POScannedCard?) -> POScannedCard? {
        if isConfident {
            return errorCorrectedCard // Enough confidence is already reached, ignored.
        }
        if let scannedCard {
            startTime = startTime ?? DispatchTime.now()
            updateFrequencies(with: scannedCard)
        }
        guard let errorCorrectedCard else {
            return nil
        }
        if let startTime {
            // swiftlint:disable:next line_length
            isConfident = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds >= Constants.errorCorrectionDuration
        }
        return errorCorrectedCard
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let errorCorrectionDuration = 3 * NSEC_PER_SEC
    }

    // MARK: - Private Properties

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
}
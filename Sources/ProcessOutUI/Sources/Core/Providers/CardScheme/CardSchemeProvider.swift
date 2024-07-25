//
//  CardSchemeProvider.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.08.2023.
//

import Foundation
@_spi(PO) import ProcessOut

// todo(andrii-vysotskyi): support more schemes
final class CardSchemeProvider {

    struct Issuer {
        let scheme: POCardScheme
        let numbers: IssuerNumbers
        let length: Int
    }

    enum IssuerNumbers {
        case range(ClosedRange<Int>), exact(Int), set(Set<Int>)
    }

    /// Returns locally generated scheme.
    func scheme(cardNumber number: String) -> POCardScheme? {
        let normalizedNumber = number
            .removingCharacters(in: .decimalDigits.inverted)
            .prefix(Constants.maximumIinLength)
        // It is possible for a card number to start with "0" but it isn't supported by the
        // implementation below because it relies on integer ranges to perform a lookup.
        guard !normalizedNumber.starts(with: "0"),
              let numberValue = Int(normalizedNumber) else {
            return nil
        }
        let issuer = issuers.first { issuer in
            let lengthDifference = normalizedNumber.count - issuer.length
            guard lengthDifference >= 0 else {
                return false
            }
            // Makes number value of equal length with issuer.length
            let value = numberValue / pow(10, lengthDifference)
            switch issuer.numbers {
            case .range(let acceptedRange):
                return acceptedRange.contains(value)
            case .set(let acceptedValues):
                return acceptedValues.contains(value)
            case .exact(let acceptedValue):
                return acceptedValue == value
            }
        }
        return issuer?.scheme
    }

    init(issuers: [Issuer]) {
        self.issuers = issuers
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let maximumIinLength = 6
    }

    // MARK: - Private Properties

    private let issuers: [Issuer]
}

extension CardSchemeProvider {

    static let shared = CardSchemeProvider(issuers: CardSchemeProvider.defaultIssuers)

    // MARK: - Private Properties

    // Based on https://www.bincodes.com/bin-list
    // Information is sorted by length to properly handle overlapping numbers (like 622126 and 62).
    private static let defaultIssuers: [Issuer] = [
        .init(scheme: .discover, numbers: .range(622126...622925), length: 6),
        .init(
            scheme: .elo,
            numbers: .set([
                401178, 401179, 431274, 438935, 451416, 457393, 457631, 457632, 504175, 506699, 506770, 506771,
                506772, 506773, 506774, 506775, 506776, 506777, 506778, 627780, 636297, 636368, 650031, 650032,
                650033, 650035, 650036, 650037, 650038, 650039, 650050, 650051, 650405, 650406, 650407, 650408,
                650409, 650485, 650486, 650487, 650488, 650489, 650530, 650531, 650532, 650533, 650534, 650535,
                650536, 650537, 650538, 650541, 650542, 650543, 650544, 650545, 650546, 650547, 650548, 650549,
                650590, 650591, 650592, 650593, 650594, 650595, 650596, 650597, 650598, 650710, 650711, 650712,
                650713, 650714, 650715, 650716, 650717, 650718, 650720, 650721, 650722, 650723, 650724, 650725,
                650726, 650727, 650901, 650902, 650903, 650904, 650905, 650906, 650907, 650908, 650909, 650970,
                650971, 650972, 650973, 650974, 650975, 650976, 650977, 650978, 651652, 651653, 651654, 651655,
                651656, 651657, 651658, 651659, 655021, 655022, 655023, 655024, 655025, 655026, 655027, 655028,
                655029, 655050, 655051, 655052, 655053, 655054, 655055, 655056, 655057, 655058
            ]),
            length: 6
        ),
        .init(
            scheme: .elo,
            numbers: .set([
                50670, 50671, 50672, 50673, 50674, 50675, 50676, 65004, 65041, 65042, 65043, 65049, 65050, 65051,
                65052, 65055, 65056, 65057, 65058, 65070, 65091, 65092, 65093, 65094, 65095, 65096, 65166, 65167,
                65500, 65501, 65503, 65504
            ]),
            length: 5
        ),
        .init(scheme: .discover, numbers: .exact(6011), length: 4),
        .init(scheme: .jcb, numbers: .range(3528...3589), length: 4),
        .init(scheme: .elo, numbers: .exact(509), length: 3),
        .init(scheme: .discover, numbers: .range(644...649), length: 3),
        .init(scheme: .dinersClubCarteBlanche, numbers: .range(300...305), length: 3),
        .init(scheme: .dinersClubInternational, numbers: .exact(309), length: 3),
        .init(scheme: .mastercard, numbers: .range(51...55), length: 2),
        .init(scheme: .discover, numbers: .exact(65), length: 2),
        .init(scheme: .unionPay, numbers: .exact(62), length: 2),
        .init(scheme: .amex, numbers: .set([34, 37]), length: 2),
        .init(scheme: .maestro, numbers: .set([50, 56, 57, 58, 59]), length: 2),
        .init(scheme: .dinersClubInternational, numbers: .set([36, 38, 39]), length: 2),
        .init(scheme: .dinersClubUnitedStatesAndCanada, numbers: .range(54...55), length: 2),
        .init(scheme: .visa, numbers: .exact(4), length: 1),
        .init(scheme: .maestro, numbers: .exact(6), length: 1)
    ]
}

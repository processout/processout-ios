//
//  CardSchemeProvider.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.08.2023.
//

import Foundation
@_spi(PO) import ProcessOut

// todo(andrii-vysotskyi): support more schemes
struct CardSchemeProvider {

    /// Returns locally generated scheme.
    func scheme(cardNumber number: String) -> String? {
        let normalizedNumber = cardNumberFormatter
            .normalized(number: number)
            .prefix(Constants.maximumIinLength)
        // It is possible for a card number to start with "0" but it isn't supported by the
        // implementation below because it relies on integer ranges to perform a lookup.
        guard !normalizedNumber.starts(with: "0"),
              let numberValue = Int(normalizedNumber) else {
            return nil
        }
        let issuer = Self.issuers.first { issuer in
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

    // MARK: - Private Nested Types

    private enum Constants {
        static let maximumIinLength = 6
    }

    private struct Issuer {
        let scheme: String
        let numbers: IssuerNumbers
        let length: Int
    }

    private enum IssuerNumbers {
        case range(ClosedRange<Int>), exact(Int), set(Set<Int>)
    }

    // MARK: - Private Properties

    // Based on https://www.bincodes.com/bin-list
    // Information is sorted by length to properly handle overlapping numbers (like 622126 and 62).
    private static let issuers: [Issuer] = [
        .init(scheme: "discover", numbers: .range(622126...622925), length: 6),
        .init(
            scheme: "elo",
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
            scheme: "elo",
            numbers: .set([
                50670, 50671, 50672, 50673, 50674, 50675, 50676, 65004, 65041, 65042, 65043, 65049, 65050, 65051,
                65052, 65055, 65056, 65057, 65058, 65070, 65091, 65092, 65093, 65094, 65095, 65096, 65166, 65167,
                65500, 65501, 65503, 65504
            ]),
            length: 5
        ),
        .init(
            scheme: "carte bancaire",
            numbers: .set([
                40100, 40209, 40220, 40221, 40223, 40355, 40593, 40594, 40657, 41503, 41505, 41506, 41507, 41509,
                41628, 41717, 41993, 42011, 42012, 42346, 43782, 43783, 43787, 43950, 43951, 43953, 44244, 44245,
                44841, 44853, 44855, 44995, 44996, 44997, 45051, 45054, 45056, 45330, 45331, 45332, 45333, 45334,
                45335, 45337, 45339, 45560, 45566, 45567, 45568, 45610, 45611, 45612, 45613, 45614, 45615, 45616,
                45617, 45618, 45619, 45620, 45621, 45622, 45623, 45624, 45625, 45626, 45627, 45628, 45629, 45720,
                45721, 45745, 45771, 45929, 45930, 45932, 45933, 45937, 45939, 45940, 45950, 45954, 45958, 46321,
                46361, 46547, 46609, 46625, 46657, 46703, 46896, 46969, 46978, 46980, 46982, 46983, 46986, 47260,
                47268, 47427, 47480, 47717, 47718, 47722, 47726, 47729, 47802, 47809, 47961, 48160, 48362, 48369,
                48373, 48651, 49702, 49703, 49704, 49706, 49707, 49708, 49709, 49710, 49711, 49712, 49713, 49714,
                49715, 49716, 49717, 49718, 49719, 49720, 49721, 49722, 49723, 49724, 49725, 49726, 49727, 49728,
                49729, 49730, 49731, 49732, 49733, 49734, 49735, 49736, 49737, 49738, 49739, 49740, 49741, 49742,
                49743, 49744, 49745, 49746, 49747, 49748, 49749, 49750, 49751, 49752, 49753, 49754, 49755, 49756,
                49757, 49758, 49759, 49760, 49761, 49762, 49763, 49764, 49765, 49766, 49767, 49768, 49769, 49770,
                49771, 49772, 49773, 49774, 49775, 49776, 49777, 49778, 49779, 49780, 49781, 49782, 49783, 49784,
                49785, 49786, 49787, 49788, 49789, 49790, 49791, 49792, 49793, 49794, 49795, 49796, 49797, 49798,
                49799, 49835, 49836, 49837, 49838, 49839, 49900, 49901, 49902, 49903, 49904, 49905, 49906, 49909,
                51300, 51301, 51302, 51303, 51310, 51311, 51312, 51313, 51314, 51315, 51316, 51317, 51318, 51319,
                51320, 51321, 51322, 51323, 51324, 51325, 51326, 51327, 51328, 51329, 51330, 51331, 51332, 51335,
                51336, 51337, 51338, 51341, 51345, 51348, 51350, 51351, 51352, 51353, 51354, 51355, 51356, 51357,
                51360, 51361, 51362, 51363, 51364, 51365, 51366, 51367, 51369, 51370, 51371, 51372, 51373, 51374,
                51375, 51376, 51377, 51378, 51379, 51385, 51386, 51390, 51521, 51620, 51623, 51736, 51750, 51810,
                51992, 52166, 52371, 52886, 52920, 52922, 52931, 52933, 52941, 52942, 52943, 52944, 52945, 52946,
                52947, 52948, 52949, 52954, 53102, 53103, 53119, 53234, 53250, 53253, 53255, 53410, 53411, 53502,
                53506, 53532, 53610, 53611, 53710, 53711, 53801, 54284, 54515, 54953, 54985, 55391, 55397, 55399,
                55420, 55426, 55496, 55700, 55886, 55888, 55892, 55961, 55980, 55981, 56124, 56125, 58170, 58171,
                58172, 58173, 58174, 58175, 58176, 58177, 58178, 58179, 67117, 67759
            ]),
            length: 5
        ),
        .init(scheme: "discover", numbers: .exact(6011), length: 4),
        .init(scheme: "jcb", numbers: .range(3528...3589), length: 4),
        .init(scheme: "elo", numbers: .exact(509), length: 3),
        .init(scheme: "discover", numbers: .range(644...649), length: 3),
        .init(scheme: "diners club carte blanche", numbers: .range(300...305), length: 3),
        .init(scheme: "diners club international", numbers: .exact(309), length: 3),
        .init(scheme: "mastercard", numbers: .range(51...55), length: 2),
        .init(scheme: "discover", numbers: .exact(65), length: 2),
        .init(scheme: "china union pay", numbers: .exact(62), length: 2),
        .init(scheme: "american express", numbers: .set([34, 37]), length: 2),
        .init(scheme: "maestro", numbers: .set([50, 56, 57, 58, 59]), length: 2),
        .init(scheme: "diners club international", numbers: .set([36, 38, 39]), length: 2),
        .init(scheme: "diners club united states & canada", numbers: .range(54...55), length: 2),
        .init(scheme: "visa", numbers: .exact(4), length: 1),
        .init(scheme: "maestro", numbers: .exact(6), length: 1)
    ]

    private let cardNumberFormatter = POCardNumberFormatter()
}

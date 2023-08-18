//
//  CardTokenizationSchemeProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.08.2023.
//

struct CardTokenizationSchemeProvider {

    /// Returns locally generated scheme.
    func scheme(cardNumber number: String) -> String? {
        struct Issuer {
            let scheme: String
            let ranges: [ClosedRange<Int>]
            let length: Int
        }
        // Based on https://www.bincodes.com/bin-list
        // todo(andrii-vysotskyi): support more schemes
        let issuers: [Issuer] = [
            .init(scheme: "uatp", ranges: [1...1], length: 1),
            .init(scheme: "visa", ranges: [4...4], length: 1),
            .init(scheme: "mastercard", ranges: [2221...2720], length: 4),
            .init(scheme: "mastercard", ranges: [51...55], length: 2),
            .init(scheme: "china union pay", ranges: [62...62], length: 2),
            .init(scheme: "american express", ranges: [34...34, 37...37], length: 2),
            .init(scheme: "discover", ranges: [6011...6011], length: 4),
            .init(scheme: "discover", ranges: [644...649], length: 3),
            .init(scheme: "discover", ranges: [65...65], length: 2),
            .init(scheme: "jcb", ranges: [3528...3589], length: 4),
            .init(scheme: "argencard", ranges: [501105...501105], length: 6)
        ]
        let normalizedNumber = cardNumberFormatter.normalized(number: number)
        let issuer = issuers.first { issuer in
            guard let leading = Int(normalizedNumber.prefix(issuer.length)) else {
                return false
            }
            return issuer.ranges.contains { $0.contains(leading) }
        }
        return issuer?.scheme
    }

    // MARK: - Private Properties

    private let cardNumberFormatter = CardNumberFormatter()
}

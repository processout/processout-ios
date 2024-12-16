//
//  CardholderNameDetector.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.11.2024.
//

import NaturalLanguage

struct CardholderNameDetector: CardAttributeDetector {

    init(restrictedWords: [String] = CardholderNameDetector.defaultRestrictedWords) {
        self.restrictedWords = restrictedWords
    }

    // MARK: -

    func firstMatch(in candidates: inout [String]) -> String? {
        for (offset, candidate) in candidates.enumerated() {
            let normalizedCandidate = candidate
                .applyingTransform(.toLatin, reverse: false)?
                .applyingTransform(.stripDiacritics, reverse: false)?
                .uppercased()
            guard let normalizedCandidate else {
                continue
            }
            var hasRestrictedWord = false
            enumerateWords(in: normalizedCandidate) { word in
                let word = String(word)
                for testWord in restrictedWords where areSimilar(string: word, and: testWord) {
                    hasRestrictedWord = true
                    break
                }
                return !hasRestrictedWord
            }
            if hasRestrictedWord {
                continue
            }
            candidates.remove(at: offset)
            return candidate
        }
        return nil
    }

    // MARK: - Private Properties

    private let restrictedWords: [String]

    // MARK: - Private Methods

    private func enumerateWords(in string: String, using block: (Substring) -> Bool) {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = string
        tokenizer.enumerateTokens(in: string.startIndex..<string.endIndex) { range, _ in
            let substring = string[range]
            return block(substring)
        }
    }

    private func areSimilar(string: String, and secondString: String) -> Bool {
        string == secondString // Check for exact match to avoid potential false negatives, e.g. Visa <-> Lisa
    }
}

extension CardholderNameDetector {

    static let defaultRestrictedWords: [String] = [
        // Card networks
        "VISA",
        "MASTERCARD",
        "AMEX",
        "AMERICAN",
        "EXPRESS",
        "DISCOVER",
        "DINERS",
        "CLUB",
        "UNION",
        "PAY",
        "JCB",
        "NETWORK",
        "INTERNATIONAL",
        "CARD",
        "MEMBER",
        "SECURE",
        "CREDIT",
        "DEBIT",
        "CHIP",
        "NFC",

        // Card labels
        "PLATINUM",
        "GOLD",
        "SILVER",
        "TITANIUM",
        "BUSINESS",
        "CORPORATE",
        "REWARD",
        "SECURED",
        "ADVANCE",
        "WORLD",
        "ELITE",
        "PREFERRED",
        "INFINITE",
        "SELECT",
        "PRIVILEGE",
        "PREMIER",
        "PLUS",
        "EDGE",
        "ULTIMATE",
        "SIGNATURE",

        // Issuing banks (Generic Terms and Widely Used Names)
        "BANK",
        "CHASE",
        "CITI",
        "WELLS",
        "FARGO",
        "CAPITAL",
        "HSBC",
        "BARCLAYS",
        "SANTANDER",
        "BBVA",
        "NATWEST",
        "RBC",
        "TD",
        "SCOTIABANK",
        "BMO",
        "SOCIETE",
        "GENERALE",
        "STANDARD",
        "CHARTERED",
        "DEUTSCHE",

        // Contact information
        "ADDRESS",
        "STREET",
        "ROAD",
        "AVENUE",
        "CITY",
        "STATE",
        "ZIP",
        "COUNTRY",
        "TELEPHONE",
        "EMAIL",

        // Security Features and Miscellaneous Text
        "VALID",
        "THRU",
        "EXPIRY",
        "DATE",
        "EXPIRES",
        "FROM",
        "UNTIL",
        "AUTHORIZED",
        "USER",
        "USE",
        "ONLY",
        "AUTHORIZATION",
        "SIGNATURE",
        "LINE",
        "VOID",
        "MAGNETIC",
        "STRIPE",
        "NUMBER",
        "CODE",
        "SECURE",

        // Generic terms
        "CONTACT",
        "SERVICE",
        "CUSTOMER",
        "SUPPORT",
        "WEBSITE",
        "HOTLINE",
        "HELP",
        "TERMS",
        "CONDITIONS",
        "LIMITATIONS"
    ]
}

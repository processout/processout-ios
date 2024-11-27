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
                .lowercased()
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
        let differencesCount = Double(string.difference(from: secondString).count)
        let distance = min(differencesCount / Double(string.count), 1)
        return distance <= 0.2
    }
}

// swiftlint:disable strict_fileprivate

extension CardholderNameDetector {

    fileprivate static let defaultRestrictedWords: [String] = [
        "visa",
        "mastercard",
        "american",
        "express",
        "netspend",
        "usaa",
        "chaseo",
        "commerce",
        "bmo",
        "capital",
        "one",
        "capitalone",
        "platinum",
        "expiry",
        "date",
        "expiration",
        "cvv",
        "cvc",
        "cash",
        "back",
        "td",
        "access",
        "international",
        "interac",
        "nterac",
        "entreprise",
        "md",
        "enterprise",
        "fifth",
        "third",
        "fifththird",
        "world",
        "rewards",
        "cardmember",
        "cardholder",
        "valued",
        "membersince",
        "cardmembersince",
        "cardholdersince",
        "freedom",
        "quicksilver",
        "penfed",
        "use",
        "subject",
        "transferable",
        "wells",
        "chase",
        "fargo",
        "hsbc",
        "citi",
        "this",
        "is",
        "to",
        "the",
        "not",
        "gto",
        "mgy",
        "sign",
        "customer",
        "debit",
        "navy",
        "thru",
        "good",
        "authorized",
        "signature",
        "credit",
        "federal",
        "union",
        "bank",
        "valid",
        "from",
        "llc",
        "business",
        "goodthru",
        "last",
        "of",
        "lastdayof",
        "check",
        "card",
        "inc",
        "first",
        "member",
        "since",
        "republic"
    ]
}

// swiftlint:enable strict_fileprivate

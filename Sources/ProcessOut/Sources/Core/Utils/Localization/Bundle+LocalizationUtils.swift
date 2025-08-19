//
//  Bundle+LocalizationUtils.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.08.2025.
//

import Foundation

extension Bundle {

    func withLocaleOverride(_ locale: Locale) -> Bundle? {
        // todo(andrii-vysotskyi): improve matching rules
        for identifierCandidate in [locale.identifier, locale.languageCode] {
            if let path = path(forResource: identifierCandidate, ofType: "lproj") {
                return Bundle(path: path)
            }
        }
        return nil
    }

    func localizedStringIfAvailable(forKey key: String, table tableName: String? = nil) -> String? {
        let string = localizedString(forKey: key, value: Constants.unknownString, table: tableName)
        return string != Constants.unknownString ? string : nil
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let unknownString = UUID().uuidString
    }
}

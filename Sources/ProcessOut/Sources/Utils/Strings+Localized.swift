//
//  Strings+Localized.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.10.2022.
//

import Foundation

extension Strings {

    /// The implementation attempts to return translation in a language that is equal to a first entry in
    /// the main bundle's `preferredLocalizations` array.
    ///
    /// It also prevents languages mismatch. For example, when the main application has both German
    /// and English as preferred languages, its interface is going to be in German. But if we support only
    /// English, our bundle would use it as a preferred language and render strings in it.
    ///
    /// If the main application uses a language that we don't support, the implementation would attempt
    /// to use strings from the main bundle so that users can add missing localizations without having to
    /// modify the SDK.
    ///
    /// The implementation falls back to the framework's bundle in case the main application doesn't
    /// provide translations for missing languages to ensure that we don't display untranslated strings.
    static func localized(_ key: String, _ table: String) -> String {
        if Bundle.main.preferredLocalizations.first == BundleLocator.bundle.preferredLocalizations.first {
            return BundleLocator.bundle.localizedString(forKey: key, value: nil, table: table)
        }
        let string = Bundle.main.localizedString(forKey: key, value: Self.unknownString, table: table)
        if string != Self.unknownString {
            return string
        }
        return BundleLocator.bundle.localizedString(forKey: key, value: nil, table: table)
    }

    // MARK: - Private Properties

    private static let unknownString = UUID().uuidString
}

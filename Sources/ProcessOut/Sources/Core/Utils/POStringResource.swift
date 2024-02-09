//
//  POStringResource.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.01.2024.
//

import Foundation

@_spi(PO) public struct POStringResource {

    /// The key to use to look up a localized string.
    let key: String

    /// The bundle containing the table’s strings file.
    let bundle: Bundle

    public init(_ key: String, bundle: Bundle, comment: String) {
        self.key = key
        self.bundle = bundle
    }

    init(_ key: String, comment: String) {
        self.key = key
        self.bundle = BundleLocator.bundle
    }
}

extension String {

    /// Creates string with given resource and replacements.
    @_spi(PO) public init(resource: POStringResource, replacements: CVarArg...) {
        let format = Self.localized(resource.key, bundle: resource.bundle)
        self = String(format: format, locale: .current, arguments: replacements)
    }

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
    private static func localized(_ key: String, bundle: Bundle) -> String {
        if Bundle.main.preferredLocalizations.first == bundle.preferredLocalizations.first {
            return bundle.localizedString(forKey: key, value: nil, table: nil)
        }
        let string = Bundle.main.localizedString(
            forKey: key, value: Constants.unknownString, table: Constants.externalTable
        )
        if string != Constants.unknownString {
            return string
        }
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let externalTable = "ProcessOut"
        static let unknownString = UUID().uuidString
    }
}

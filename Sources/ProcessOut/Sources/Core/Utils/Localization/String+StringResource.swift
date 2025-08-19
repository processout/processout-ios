//
//  String+StringResource.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.08.2025.
//

import Foundation

extension String {

    /// Creates string with given resource and replacements.
    @_spi(PO)
    public init(
        resource: POStringResource,
        configuration: LocalizationConfiguration = .device(),
        replacements: CVarArg...
    ) {
        let format = Self.localized(resource.key, bundle: resource.bundle, configuration: configuration)
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
    private static func localized(_ key: String, bundle: Bundle, configuration: LocalizationConfiguration) -> String {
        if let localeOverride = configuration.localeOverride {
            if let bundle = Bundle.main.withLocaleOverride(localeOverride),
               let string = bundle.localizedStringIfAvailable(forKey: key, table: Constants.externalTable) {
                return string
            }
            if let string = bundle.withLocaleOverride(localeOverride)?.localizedStringIfAvailable(forKey: key) {
                return string
            }
        }
        if Bundle.main.preferredLocalizations.first == bundle.preferredLocalizations.first {
            return bundle.localizedString(forKey: key, value: nil, table: nil)
        }
        if let string = Bundle.main.localizedStringIfAvailable(forKey: key, table: Constants.externalTable) {
            return string
        }
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let externalTable = "ProcessOut"
    }
}

//
//  Strings+PreferredLocalization.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.10.2022.
//

import Foundation

enum Strings {

    static var preferredLocalization: String {
        // todo(andrii-vysotskyi): it should be possible to inject supported localizations
        // instead of only relying on languages that are supported by current bundle.
        let bundle: Bundle
        if Bundle.main.preferredLocalizations.first == BundleLocator.bundle.preferredLocalizations.first {
            bundle = BundleLocator.bundle
        } else if hasStringsPreferredLocalization(ofType: "strings", in: .main) {
            bundle = Bundle.main
        } else if hasStringsPreferredLocalization(ofType: "stringsdict", in: .main) {
            bundle = Bundle.main
        } else {
            bundle = BundleLocator.bundle
        }
        // swiftlint:disable:next force_unwrapping
        return bundle.preferredLocalizations.first!
    }

    // MARK: - Private Methods

    private static func hasStringsPreferredLocalization(ofType type: String, in bundle: Bundle) -> Bool {
        let path = bundle.path(
            forResource: "ProcessOut",
            ofType: type,
            inDirectory: nil,
            forLocalization: bundle.preferredLocalizations.first
        )
        return path != nil
    }
}

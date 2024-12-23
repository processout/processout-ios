//
//  RegexProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2023.
//

import Foundation

// swiftlint:disable legacy_objc_type

@_spi(PO)
public final class PORegexProvider: @unchecked Sendable {

    public static let shared = PORegexProvider()

    // MARK: - RegexProviderType

    /// Returns regular expression with given pattern if one is valid.
    public func regex(with pattern: String) -> NSRegularExpression? {
        if let regex = cache.object(forKey: pattern as NSString) {
            return regex
        }
        if let regex = try? NSRegularExpression(pattern: pattern) {
            cache.setObject(regex, forKey: pattern as NSString)
            return regex
        }
        return nil
    }

    // MARK: - Private Methods

    private init() {
        cache = NSCache()
    }

    // MARK: - Private Properties

    private let cache: NSCache<NSString, NSRegularExpression>
}

// swiftlint:enable legacy_objc_type

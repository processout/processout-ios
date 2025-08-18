//
//  LocalizationConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.08.2025.
//

import Foundation

/// The localization parameters.
public struct LocalizationConfiguration: Equatable {

    /// Explicitly overridden locale.
    @_spi(PO)
    public let localeOverride: Locale?
}

extension LocalizationConfiguration {

    public static func device() -> Self {
        .init(localeOverride: nil)
    }

    public static func custom(localeIdentifier: String) -> Self {
        .init(localeOverride: .init(identifier: localeIdentifier))
    }
}

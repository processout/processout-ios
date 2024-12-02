//
//  POCardScannerConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.12.2024.
//

/// Card scanner view configuration.
@_spi(PO)
@MainActor
public struct POCardScannerConfiguration: Sendable {

    /// Custom title. Use empty string to hide title.
    public let title: String?

    /// Custom description. Use empty string to hide description.
    public let description: String?

    public init(title: String? = nil, description: String? = nil) {
        self.title = title
        self.description = description
    }
}

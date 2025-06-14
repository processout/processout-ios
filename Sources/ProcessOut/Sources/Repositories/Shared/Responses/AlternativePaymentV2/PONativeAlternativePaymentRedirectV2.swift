//
//  PONativeAlternativePaymentRedirectV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.06.2025.
//

import Foundation

/// Redirect details.
@_spi(PO)
public struct PONativeAlternativePaymentRedirectV2: Decodable, Sendable {

    /// Destination URL.
    public let url: URL

    /// Display hint describing redirect purpose.
    public let hint: String
}

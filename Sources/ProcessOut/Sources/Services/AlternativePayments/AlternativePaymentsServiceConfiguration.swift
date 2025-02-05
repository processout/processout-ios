//
//  POAlternativePaymentsServiceConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.02.2024.
//

import Foundation

/// Alternative payments service configuration.
@_spi(PO)
public struct POAlternativePaymentsServiceConfiguration: Sendable {

    /// Project ID.
    let projectId: String

    /// Base URL.
    let baseUrl: URL
}

//
//  DefaultSafariViewModelConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

import Foundation

@available(*, deprecated)
struct DefaultSafariViewModelConfiguration {

    /// Return url specified when creating invoice.
    let returnUrl: URL

    /// Optional timeout.
    let timeout: TimeInterval?
}

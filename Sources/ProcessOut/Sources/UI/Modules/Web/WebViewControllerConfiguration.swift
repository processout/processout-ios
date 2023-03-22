//
//  WebViewControllerConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.03.2023.
//

import Foundation

struct WebViewControllerConfiguration {

    /// Supported return urls.
    let returnUrls: [URL]

    /// SDK version.
    let version: String

    /// Optional timeout.
    let timeout: TimeInterval?
}

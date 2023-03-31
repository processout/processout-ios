//
//  HttpConnectorConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.03.2023.
//

import Foundation

struct HttpConnectorConfiguration {

    /// Base url to use to send requests to.
    let baseUrl: URL

    /// SDK version.
    let version: String
}

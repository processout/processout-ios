//
//  HttpConnectorRequestMapperConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.03.2023.
//

import Foundation

struct HttpConnectorConfiguration: Sendable {

    /// Base url to use to send requests to.
    let baseUrl: URL

    /// Project id to associate requests with.
    let projectId: String

    /// Project's private key.
    let privateKey: String?

    /// Current session ID.
    let sessionId: String

    /// SDK version.
    let version: String
}

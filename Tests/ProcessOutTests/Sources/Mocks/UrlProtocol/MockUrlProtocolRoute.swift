//
//  MockUrlProtocolRoute.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 28.03.2023.
//

import Foundation

struct MockUrlProtocolRoute {

    /// Route method.
    let method: String?

    /// Url pattern to match.
    let path: String

    /// Response provider.
    let handler: (URLRequest) async throws -> (URLResponse, Data)
}

//
//  WebAuthenticationSession.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 01.08.2024.
//

import Foundation

protocol WebAuthenticationSession: Sendable {

    /// Begins a web authentication session.
    func authenticate(
        using url: URL, callbackScheme: String?, additionalHeaderFields: [String: String]?
    ) async throws -> URL
}

extension WebAuthenticationSession {

    /// Begins a web authentication session.
    func authenticate(
        using url: URL, callbackScheme: String? = nil, additionalHeaderFields headerFields: [String: String]? = nil
    ) async throws -> URL {
        try await authenticate(using: url, callbackScheme: callbackScheme, additionalHeaderFields: headerFields)
    }
}

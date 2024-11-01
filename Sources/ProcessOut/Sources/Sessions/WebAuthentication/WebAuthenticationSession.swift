//
//  WebAuthenticationSession.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 01.08.2024.
//

import Foundation

protocol WebAuthenticationSession: Sendable {

    /// Begins a web authentication session.
    func authenticate(using request: WebAuthenticationRequest) async throws -> URL
}

//
//  POWebAuthenticationSession.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 01.08.2024.
//

import Foundation

@_spi(PO)
public protocol POWebAuthenticationSession: Sendable {

    /// Begins a web authentication session.
    func authenticate(using request: POWebAuthenticationRequest) async throws -> URL
}

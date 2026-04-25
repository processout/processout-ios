//
//  POWebAuthenticationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.10.2024.
//

import Foundation

@_spi(PO)
public struct POWebAuthenticationRequest: Sendable {

    /// A URL pointing to the authentication webpage.
    public let url: URL

    /// Callback.
    public let callback: POWebAuthenticationCallback?

    /// A boolean value that indicates whether the session should ask the browser for
    /// a private authentication session.
    public let prefersEphemeralSession: Bool

    public init(url: URL, callback: POWebAuthenticationCallback?, prefersEphemeralSession: Bool) {
        self.url = url
        self.callback = callback
        self.prefersEphemeralSession = prefersEphemeralSession
    }
}

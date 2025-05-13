//
//  WebAuthenticationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.10.2024.
//

import Foundation

struct WebAuthenticationRequest: Sendable {

    /// A URL pointing to the authentication webpage.
    let url: URL

    /// Callback.
    let callback: POWebAuthenticationCallback?

    /// A boolean value that indicates whether the session should ask the browser for
    /// a private authentication session.
    let prefersEphemeralSession: Bool
}

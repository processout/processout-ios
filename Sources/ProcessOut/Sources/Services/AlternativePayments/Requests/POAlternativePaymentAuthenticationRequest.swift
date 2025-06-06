//
//  POAlternativePaymentAuthenticationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.01.2025.
//

import Foundation

/// Alternative payment raw authentication request.
public struct POAlternativePaymentAuthenticationRequest: Sendable, Codable {

    /// URL where user should be redirected to perform authentication.
    public let url: URL

    /// An object used to evaluate navigation events in a web authentication session.
    @POExcludedEncodable
    public private(set) var callback: POWebAuthenticationCallback?

    /// A boolean value that indicates whether the session should ask the browser for a
    /// private authentication session.
    ///
    /// Set `prefersEphemeralSession` to true to request that the browser
    /// doesn’t share cookies or other browsing data between the authentication session
    /// and the user’s normal browser session.
    ///
    /// The value of this property is `true` by default.
    @POExcludedEncodable
    public private(set) var prefersEphemeralSession: Bool

    public init(url: URL, callback: POWebAuthenticationCallback? = nil, prefersEphemeralSession: Bool = true) {
        self.url = url
        self.callback = callback
        self.prefersEphemeralSession = prefersEphemeralSession
    }
}

//
//  POWebAuthenticationSessionCallback.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.05.2024.
//

import Foundation

/// An object used to evaluate navigation events in an authentication session.
public struct POWebAuthenticationSessionCallback: @unchecked Sendable {

    /// Creates a callback object that matches against URLs with the given custom scheme.
    /// - Parameter customScheme: The custom scheme that the app expects in the callback URL.
    public static func customScheme(_ customScheme: String) -> Self {
        Self { $0.scheme == customScheme }
    }

    /// Check whether a given main-frame navigation URL matches the callback expected by the client app.
    let matchesURL: (_ url: URL) -> Bool
}

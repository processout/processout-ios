//
//  CustomerActionRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.01.2025.
//

struct CustomerActionRequest: Sendable {

    /// Customer action to handle.
    let customerAction: _CustomerAction

    /// An object used to evaluate navigation events in a web
    /// authentication session.
    let webAuthenticationCallback: POWebAuthenticationCallback?

    /// A boolean value that indicates whether the session should ask the
    /// browser for a private authentication session.
    let prefersEphemeralWebAuthenticationSession: Bool
}

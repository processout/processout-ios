//
//  ThreeDSServiceFactoryInput.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.09.2025.
//

/// Input required to initialize and configure a `ThreeDSService` via `ThreeDSServiceFactory`.
struct ThreeDSServiceFactoryInput {

    /// An optional locale identifier used for localization override.
    let localeIdentifier: String?

    /// An object used to evaluate navigation events in a web authentication session.
    let webAuthenticationCallback: POWebAuthenticationCallback?
}

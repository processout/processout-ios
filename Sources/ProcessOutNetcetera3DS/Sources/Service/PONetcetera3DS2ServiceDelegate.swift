//
//  PONetcetera3DS2ServiceDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

import ProcessOut
import ThreeDS_SDK

public protocol PONetcetera3DS2ServiceDelegate: AnyObject, Sendable {

    /// Asks delegate whether service should continue with given warnings. Default implementation
    /// ignores warnings and returns `true`.
    @MainActor
    func netcetera3DS2Service(
        _ service: PONetcetera3DS2Service, shouldContinueWith warnings: [Warning]
    ) async -> Bool
}

// todo(andrii-vysotskyi): decide whether locale and UI tweaks should be passed via delegate or statically

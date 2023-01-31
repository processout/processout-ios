//
//  ProcessOutApiConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

import Foundation

/// Defines configuration parameters that are used to create API singleton. In order to create instance
/// of this structure one should use ``ProcessOutApiConfiguration/production(projectId:)``
/// method.
public struct ProcessOutApiConfiguration {

    /// Project id.
    public let projectId: String

    /// Boolean value that indicates whether SDK should operate in debug mode. At this moment it
    /// only affects logging level.
    /// - NOTE: Debug logs may contain sensitive data.
    public let isDebug: Bool

    /// Project's password.
    /// - Warning: this is only intended to be used for testing purposes storing your private key
    /// inside application is extremely dangerous and is highly discouraged.
    @_spi(PO) public let password: String?

    /// Api base URL.
    let apiBaseUrl: URL

    /// Checkout base URL.
    let checkoutBaseUrl: URL
}

extension ProcessOutApiConfiguration {

    /// Creates production configuration.
    public static func production(projectId: String, isDebug: Bool = false) -> Self {
        // swiftlint:disable force_unwrapping
        let apiBaseUrl = URL(string: "https://api.processout.com")!
        let checkoutBaseUrl = URL(string: "https://checkout.processout.com")!
        // swiftlint:enable force_unwrapping
        return ProcessOutApiConfiguration(
            projectId: projectId,
            isDebug: isDebug,
            password: nil,
            apiBaseUrl: apiBaseUrl,
            checkoutBaseUrl: checkoutBaseUrl
        )
    }

    /// Creates staging configuration.
    @_spi(PO)
    public static func staging(projectId: String, password: String?, apiBaseUrl: URL, checkoutBaseUrl: URL) -> Self {
        ProcessOutApiConfiguration(
            projectId: projectId,
            isDebug: true,
            password: password,
            apiBaseUrl: apiBaseUrl,
            checkoutBaseUrl: checkoutBaseUrl
        )
    }
}

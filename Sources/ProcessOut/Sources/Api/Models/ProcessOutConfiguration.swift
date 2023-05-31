//
//  ProcessOutConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

import Foundation

@available(*, deprecated, renamed: "ProcessOutConfiguration")
public typealias ProcessOutApiConfiguration = ProcessOutConfiguration

/// Defines configuration parameters that are used to create API singleton. In order to create instance
/// of this structure one should use ``ProcessOutConfiguration/production(projectId:isDebug:)``
/// method.
public struct ProcessOutConfiguration {

    /// Project id.
    public let projectId: String

    /// Boolean value that indicates whether SDK should operate in debug mode. At this moment it
    /// only affects logging level.
    /// - NOTE: Debug logs may contain sensitive data.
    public let isDebug: Bool

    /// Host application version. Providing this value helps ProcessOut to troubleshoot potential
    /// issues.
    public let appVersion: String?

    /// Project's private key.
    /// - Warning: this is only intended to be used for testing purposes storing your private key
    /// inside application is extremely dangerous and is highly discouraged.
    @_spi(PO)
    public let privateKey: String?

    /// Api base URL.
    let apiBaseUrl: URL

    /// Checkout base URL.
    let checkoutBaseUrl: URL
}

extension ProcessOutConfiguration {

    /// Creates production configuration.
    public static func production(projectId: String, isDebug: Bool = false, appVersion: String? = nil) -> Self {
        // swiftlint:disable force_unwrapping
        let apiBaseUrl = URL(string: "https://api.processout.com")!
        let checkoutBaseUrl = URL(string: "https://checkout.processout.com")!
        // swiftlint:enable force_unwrapping
        return ProcessOutConfiguration(
            projectId: projectId,
            isDebug: isDebug,
            appVersion: appVersion,
            privateKey: nil,
            apiBaseUrl: apiBaseUrl,
            checkoutBaseUrl: checkoutBaseUrl
        )
    }

    /// Creates test configuration.
    @_spi(PO)
    public static func test(projectId: String, privateKey: String?, apiBaseUrl: URL, checkoutBaseUrl: URL) -> Self {
        ProcessOutConfiguration(
            projectId: projectId,
            isDebug: true,
            appVersion: nil,
            privateKey: privateKey,
            apiBaseUrl: apiBaseUrl,
            checkoutBaseUrl: checkoutBaseUrl
        )
    }
}

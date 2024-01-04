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
/// of this structure one should use ``ProcessOutConfiguration/production(projectId:appVersion:isDebug:)``
/// method.
public struct ProcessOutConfiguration {

    /// Project id.
    public let projectId: String

    /// Host application version. Providing this value helps ProcessOut to troubleshoot potential
    /// issues.
    public let appVersion: String?

    /// Boolean value that indicates whether SDK should operate in debug mode. At this moment it
    /// only affects logging level.
    /// - NOTE: Debug logs may contain sensitive data.
    public let isDebug: Bool

    /// Project's private key.
    /// - Warning: this is only intended to be used for testing purposes storing your private key
    /// inside application is extremely dangerous and is highly discouraged.
    @_spi(PO)
    public let privateKey: String?

    /// Api base URL.
    let apiBaseUrl = URL(string: "https://api.processout.ninja")! // swiftlint:disable:this force_unwrapping

    /// Checkout base URL.
    let checkoutBaseUrl = URL(string: "https://checkout.processout.ninja")! // swiftlint:disable:this force_unwrapping
}

extension ProcessOutConfiguration {

    /// Creates production configuration.
    public static func production(projectId: String, appVersion: String? = nil, isDebug: Bool = false) -> Self {
        ProcessOutConfiguration(projectId: projectId, appVersion: appVersion, isDebug: isDebug, privateKey: nil)
    }

    /// Creates debug production configuration with optional private key.
    @_spi(PO)
    public static func production(projectId: String, privateKey: String? = nil) -> Self {
        ProcessOutConfiguration(projectId: projectId, appVersion: nil, isDebug: true, privateKey: privateKey)
    }
}

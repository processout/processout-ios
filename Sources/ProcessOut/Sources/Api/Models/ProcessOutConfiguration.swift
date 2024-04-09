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

    /// Session ID is a constant value
    @_spi(PO)
    public let sessionId = UUID().uuidString

    /// Boolean value that indicates whether SDK should operate in debug mode. At this moment it
    /// only affects logging level.
    /// - NOTE: Debug logs may contain sensitive data.
    public let isDebug: Bool

    /// Boolean value indicating whether remote telemetry is enabled.
    public let isTelemetryEnabled: Bool

    /// Project's private key.
    /// - Warning: this is only intended to be used for testing purposes storing your private key
    /// inside application is extremely dangerous and is highly discouraged.
    @_spi(PO)
    public let privateKey: String?

    /// Api base URL.
    let apiBaseUrl = URL(string: "https://api.processout.com")! // swiftlint:disable:this force_unwrapping

    /// Checkout base URL.
    let checkoutBaseUrl = URL(string: "https://checkout.processout.com")! // swiftlint:disable:this force_unwrapping
}

extension ProcessOutConfiguration {

    /// Creates production configuration.
    public static func production(
        projectId: String, appVersion: String? = nil, isDebug: Bool = false, isTelemetryEnabled: Bool = true
    ) -> Self {
        .init(
            projectId: projectId,
            appVersion: appVersion,
            isDebug: isDebug,
            isTelemetryEnabled: isTelemetryEnabled,
            privateKey: nil
        )
    }

    /// Creates debug production configuration with optional private key.
    @_spi(PO)
    public static func production(projectId: String, privateKey: String? = nil) -> Self {
        .init(projectId: projectId, appVersion: nil, isDebug: true, isTelemetryEnabled: false, privateKey: privateKey)
    }
}

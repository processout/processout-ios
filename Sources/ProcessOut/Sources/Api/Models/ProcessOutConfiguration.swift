//
//  ProcessOutConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

import Foundation

/// Defines configuration parameters that are used to create API singleton. In order to create instance
/// of this structure one should use ``ProcessOutConfiguration/init(projectId:application:isDebug:isTelemetryEnabled:)``
/// method.
public struct ProcessOutConfiguration: Sendable {

    public struct Application: Sendable {

        /// Application name.
        public let name: String?

        /// Host application version. Providing this value helps ProcessOut to troubleshoot potential issues.
        public let version: String?

        public init(name: String? = nil, version: String? = nil) {
            self.name = name
            self.version = version
        }
    }

    /// Project id.
    public let projectId: String

    /// Application name.
    public let application: Application?

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

    /// Creates configuration.
    public init(
        projectId: String,
        application: Application? = nil,
        isDebug: Bool = false,
        isTelemetryEnabled: Bool = true
    ) {
        self.projectId = projectId
        self.application = application
        self.isDebug = isDebug
        self.isTelemetryEnabled = isTelemetryEnabled
        self.privateKey = nil
    }

    /// Creates debug configuration.
    @_spi(PO)
    public init(projectId: String, privateKey: String) {
        self.projectId = projectId
        self.application = nil
        self.isDebug = true
        self.isTelemetryEnabled = false
        self.privateKey = privateKey
    }

    /// Api base URL.
    let apiBaseUrl = URL(string: "https://api.processout.com")! // swiftlint:disable:this force_unwrapping

    /// Checkout base URL.
    let checkoutBaseUrl = URL(string: "https://checkout.processout.com")! // swiftlint:disable:this force_unwrapping
}

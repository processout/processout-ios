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

    public struct Application: Hashable {

        /// Application name.
        public let name: String?

        /// Host application version. Providing this value helps ProcessOut to troubleshoot potential issues.
        public let version: String?

        public init(name: String? = nil, version: String? = nil) {
            self.name = name
            self.version = version
        }
    }

    /// Environment.
    @_spi(PO)
    public struct Environment: Hashable {

        /// Api base URL.
        let apiBaseUrl: URL

        /// Checkout base URL.
        let checkoutBaseUrl: URL
    }

    /// Project id.
    public let projectId: String

    /// Project's private key.
    /// - Warning: this is only intended to be used for testing purposes storing your private key
    /// inside application is extremely dangerous and is highly discouraged.
    @_spi(PO)
    public let privateKey: String?

    /// Application name.
    public let application: Application?

    /// Host application version. Providing this value helps ProcessOut to troubleshoot potential
    /// issues.
    @available(*, deprecated, renamed: "application.version")
    public var appVersion: String? {
        application?.version
    }

    /// Session ID is a constant value
    @_spi(PO)
    public let sessionId = UUID().uuidString

    /// Boolean value that indicates whether SDK should operate in debug mode. At this moment it
    /// only affects logging level.
    /// - NOTE: Debug logs may contain sensitive data.
    public let isDebug: Bool

    /// Boolean value indicating whether remote telemetry is enabled.
    public let isTelemetryEnabled: Bool

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
        self.environment = .production
    }

    /// Creates debug configuration.
    @_spi(PO)
    public init(
        projectId: String,
        privateKey: String? = nil,
        environment: ProcessOutConfiguration.Environment
    ) {
        self.projectId = projectId
        self.privateKey = privateKey
        self.application = nil
        self.isDebug = true
        self.isTelemetryEnabled = true
        self.environment = environment
    }

    // MARK: - Internal Properties

    /// Project environment.
    let environment: Environment
}

extension ProcessOutConfiguration {

    /// Creates production configuration.
    ///
    /// - Parameters:
    ///   - appVersion: when application parameter is set, it takes precedence over this parameter.
    @available(*, deprecated, message: "Use initialiser directly.")
    public static func production(
        projectId: String,
        application: Application? = nil,
        appVersion: String? = nil,
        isDebug: Bool = false,
        isTelemetryEnabled: Bool = true
    ) -> Self {
        ProcessOutConfiguration(
            projectId: projectId,
            application: application ?? .init(name: nil, version: appVersion),
            isDebug: isDebug,
            isTelemetryEnabled: isTelemetryEnabled
        )
    }
}

// swiftlint:disable force_unwrapping

extension ProcessOutConfiguration.Environment {

    /// Production environment.
    public static let production = Self(
        apiBaseUrl: URL(string: "https://api.processout.com")!,
        checkoutBaseUrl: URL(string: "https://checkout.processout.com")!
    )

    /// Staging environment.
    public static let stage = Self(
        apiBaseUrl: URL(string: "https://api.processout.ninja")!,
        checkoutBaseUrl: URL(string: "https://checkout.processout.ninja")!
    )
}

// swiftlint:enable force_unwrapping

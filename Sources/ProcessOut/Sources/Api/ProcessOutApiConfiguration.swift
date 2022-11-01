//
//  ProcessOutApiConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

public struct ProcessOutApiConfiguration {

    public enum Environment {
        case production, staging
    }

    // MARK: -

    /// Project id.
    public let projectId: String

    /// Project's password.
    /// - Warning: this is only intended to be used for testing purposes storing your private key
    /// inside application is extremely dangerous and is highly discouraged.
    @_spi(PO) public let password: String?

    /// Environment to use.
    /// - NOTE: `Environment.staging` is intented ONLY for internal use.
    @_spi(PO) public let environment: Environment

    /// Creates configuration instance.
    public init(projectId: String) {
        self.projectId = projectId
        self.password = nil
        self.environment = .production
    }

    /// Creates configuration instance.
    @_spi(PO)
    public init(projectId: String, password: String, environment: Environment) {
        self.projectId = projectId
        self.password = password
        self.environment = environment
    }
}

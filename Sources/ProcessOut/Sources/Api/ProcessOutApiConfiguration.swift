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

    /// Environment to use.
    /// - NOTE: `Environment.staging` is intented ONLY for internal use.
    public let environment: Environment

    /// Creates configuration instance.
    public init(projectId: String, environment: Environment = .production) {
        self.projectId = projectId
        self.environment = environment
    }
}

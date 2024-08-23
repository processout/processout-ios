//
//  LocalizedStringResource+Configuration.swift
//  Example
//
//  Created by Andrii Vysotskyi on 23.08.2024.
//

import Foundation

extension LocalizedStringResource {

    enum Configuration {

        /// Screen title.
        static let title = LocalizedStringResource("configuration.title")

        /// Project.
        static let project = LocalizedStringResource("configuration.project")

        /// Project ID.
        static let projectId = LocalizedStringResource("configuration.project-id")

        /// Project key.
        static let projectKey = LocalizedStringResource("configuration.project-key")

        /// Environment.
        static let environment = LocalizedStringResource("configuration.environment")

        /// Production environment.
        static let productionEnvironment = LocalizedStringResource("configuration.production-environment")

        /// Stage environment.
        static let stageEnvironment = LocalizedStringResource("configuration.stage-environment")

        /// Customer.
        static let customer = LocalizedStringResource("configuration.customer")

        /// Customer ID.
        static let customerId = LocalizedStringResource("configuration.customer-id")

        /// Submit button title.
        static let submit = LocalizedStringResource("configuration.submit")
    }
}

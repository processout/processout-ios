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

        /// Generic ID.
        static let id = LocalizedStringResource("configuration.id")

        /// Project.
        static let project = LocalizedStringResource("configuration.project")

        /// Project key.
        static let privateKey = LocalizedStringResource("configuration.private-key")

        /// Environment.
        static let environment = LocalizedStringResource("configuration.environment")

        /// Production environment.
        static let productionEnvironment = LocalizedStringResource("configuration.production-environment")

        /// Stage environment.
        static let stageEnvironment = LocalizedStringResource("configuration.stage-environment")

        /// Customer.
        static let customer = LocalizedStringResource("configuration.customer")

        /// ApplePay.
        static let applePay = LocalizedStringResource("configuration.apple-pay")

        /// ApplePay merchant ID..
        static let merchantId = LocalizedStringResource("configuration.merchant-id")

        /// Submit button title.
        static let submit = LocalizedStringResource("configuration.submit")
    }
}

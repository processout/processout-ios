//
//  ConfigurationViewModelState.swift
//  Example
//
//  Created by Andrii Vysotskyi on 23.08.2024.
//

@_spi(PO) import ProcessOut

struct ConfigurationViewModelState {

    struct Environment: Identifiable {

        let id: ProcessOutConfiguration.Environment

        /// Environment name.
        let name: String
    }

    /// Project ID.
    var projectId: String

    /// Project key.
    var projectKey: String

    /// Available environments.
    var environments: PickerData<Environment, ProcessOutConfiguration.Environment>

    /// Customer ID.
    var customerId: String

    /// ApplePay Merchant ID.
    var merchantId: String
}

extension ConfigurationViewModelState {

    /// Idle state.
    static var idle: ConfigurationViewModelState {
        let environmentSources: [Environment] = [
            .init(id: .production, name: String(localized: .Configuration.productionEnvironment)),
            .init(id: .stage, name: String(localized: .Configuration.stageEnvironment))
        ]
        let environments: PickerData<Environment, ProcessOutConfiguration.Environment> = .init(
            sources: environmentSources, id: \.id, selection: .production
        )
        return .init(projectId: "", projectKey: "", environments: environments, customerId: "", merchantId: "")
    }
}

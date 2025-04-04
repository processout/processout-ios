//
//  AlternativePaymentsInteractorState.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

import Foundation
import ProcessOut

enum AlternativePaymentsInteractorState {

    struct Starting: Identifiable {

        let id: String

        /// Currently set filter.
        let filter: POAllGatewayConfigurationsRequest.Filter

        /// Task associated with start operation.
        let task: Task<Void, Never>
    }

    struct Started {

        /// Available gateway configurations.
        let gatewayConfigurations: [POGatewayConfiguration]

        /// Currently set filter.
        let filter: POAllGatewayConfigurationsRequest.Filter
    }

    /// Interactor is idle.
    case idle

    /// Interactor is currently loading data that is required to start.
    case starting(Starting)

    /// Interactor has started and is operational.
    case started(Started)

    /// Interactor did fail to start.
    case failure(Error)
}

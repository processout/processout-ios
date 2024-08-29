//
//  AlternativePaymentsInteractorState.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

import Foundation
@_spi(PO) import ProcessOut

enum AlternativePaymentsInteractorState {

    struct Started {

        /// Available gateway configurations.
        let gatewayConfigurations: [POGatewayConfiguration]

        /// Currently set filter.
        let filter: POAllGatewayConfigurationsRequest.Filter?
    }

    /// Interactor is idle.
    case idle

    /// Interactor is currently loading data that is required to start.
    case starting

    /// Interactor has started and is operational.
    case started(Started)

    /// Interactor is currently restarting.
    case restarting(snapshot: Started)

    /// Interactor did fail to start.
    case failure(Error)
}

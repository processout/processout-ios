//
//  AlternativePaymentMethodsInteractorType.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

@_spi(PO) import ProcessOut

protocol AlternativePaymentMethodsInteractorType: InteractorType<AlternativePaymentMethodsInteractorState> {

    /// Restarts interactor.
    func restart()

    /// Creates invoice and calls success closure if operation completes with success.
    func createInvoice(currencyCode: String, success: @escaping (_ invoice: POInvoice) -> Void)

    /// Loads more data if possible.
    func loadMore()
}

enum AlternativePaymentMethodsInteractorState {

    struct Started {

        /// Available gateway configurations.
        let gatewayConfigurations: [POGatewayConfiguration]

        /// Boolean flag indicating if more configurations are available.
        let areMoreAvaiable: Bool
    }

    struct LoadingMore {

        /// Available gateway configurations.
        let gatewayConfigurations: [POGatewayConfiguration]
    }

    /// Interactor is idle.
    case idle

    /// Interactor is currently loading data that is required to start.
    case starting

    /// Interactor has started and is operational.
    case started(Started)

    /// More items are being loaded.
    case loadingMore(LoadingMore)

    /// Interactor is currently restarting.
    case restarting(snapshot: Started)

    /// New invoice is currently being created.
    case creatingInvoice(snapshot: Started)

    /// Interactor did fail to start.
    case failure(PORepositoryFailure)
}

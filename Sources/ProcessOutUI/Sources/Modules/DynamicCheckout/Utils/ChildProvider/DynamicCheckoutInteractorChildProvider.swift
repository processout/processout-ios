//
//  DynamicCheckoutInteractorChildProvider.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.04.2024.
//

@_spi(PO) import ProcessOut

/// - NOTE: Your implementation should expect that instances created
/// by provider are going to be different every time you call a method.
@MainActor
protocol DynamicCheckoutInteractorChildProvider {

    /// Creates and returns card tokenization interactor.
    func cardTokenizationInteractor(
        invoiceId: String, configuration: PODynamicCheckoutPaymentMethod.CardConfiguration
    ) -> any CardTokenizationInteractor

    /// Creates and returns native APM interactor..
    func nativeAlternativePaymentInteractor(
        invoiceId: String, gatewayConfigurationId: String
    ) -> any NativeAlternativePaymentInteractor
}

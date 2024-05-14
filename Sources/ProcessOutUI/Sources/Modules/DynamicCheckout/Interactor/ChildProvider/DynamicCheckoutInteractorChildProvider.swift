//
//  DynamicCheckoutInteractorChildProvider.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.04.2024.
//

@_spi(PO) import ProcessOut

/// - NOTE: Your implementation should expect that instanes created
/// by provider are going to be different every time you call a method.
protocol DynamicCheckoutInteractorChildProvider {

    /// Creates and returns card tokenization interactor.
    func cardTokenizationInteractor() -> any CardTokenizationInteractor

    /// Creates and returns card tokenization interactor.
    func nativeAlternativePaymentInteractor(gatewayId: String) -> any NativeAlternativePaymentInteractor
}

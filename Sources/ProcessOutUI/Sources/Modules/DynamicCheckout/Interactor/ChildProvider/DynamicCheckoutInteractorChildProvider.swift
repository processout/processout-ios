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
    func cardTokenizationInteractor(delegate: POCardTokenizationDelegate) -> any CardTokenizationInteractor

    /// Creates and returns card tokenization interactor.
    func nativeAlternativePaymentInteractor(
        gatewayId: String, delegate: PONativeAlternativePaymentDelegate
    ) -> any NativeAlternativePaymentInteractor
}

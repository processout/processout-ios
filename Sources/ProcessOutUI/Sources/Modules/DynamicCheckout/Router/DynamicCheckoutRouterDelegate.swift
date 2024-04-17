//
//  DynamicCheckoutRouterDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.04.2024.
//

protocol DynamicCheckoutRouterDelegate: AnyObject {

    /// Notifies delegate that router is about to route to native APM and requests
    /// interactor to instantiate related view.
    func router(
        _ router: any Router<DynamicCheckoutRoute>,
        willRouteToNativeAlternativePaymentWith gatewayConfigurationId: String
    ) -> any NativeAlternativePaymentInteractor

    /// Notifies delegate that router is about to route to card tokenization and requests
    /// interactor to instantiate related view.
    func routerWillRouteToCardTokenization(_ router: any Router<DynamicCheckoutRoute>) -> any CardTokenizationInteractor
}

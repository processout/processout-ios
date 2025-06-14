//
//  NativeAlternativePaymentServiceAdapterResponse.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.06.2025.
//

@_spi(PO) import ProcessOut

struct NativeAlternativePaymentServiceAdapterResponse {

    /// Payment state.
    let state: PONativeAlternativePaymentStateV2

    /// UI elements.
    let elements: [PONativeAlternativePaymentElementV2]?

    /// Redirect details.
    let redirect: PONativeAlternativePaymentRedirectV2?
}

extension NativeAlternativePaymentServiceAdapterResponse {

    init(authorizationResponse: PONativeAlternativePaymentAuthorizationResponseV2) {
        self.state = authorizationResponse.state
        self.elements = authorizationResponse.elements
        self.redirect = authorizationResponse.redirect
    }

    init(tokenizationResponse: PONativeAlternativePaymentTokenizationResponseV2) {
        self.state = tokenizationResponse.state
        self.elements = tokenizationResponse.elements
        self.redirect = tokenizationResponse.redirect
    }
}

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

    /// Next step if any.
    let nextStep: PONativeAlternativePaymentNextStepV2?

    /// Instructions providing additional information to customer and/or describing additional actions.
    let customerInstructions: [PONativeAlternativePaymentCustomerInstructionV2]?
}

extension NativeAlternativePaymentServiceAdapterResponse {

    init(authorizationResponse: PONativeAlternativePaymentAuthorizationResponseV2) {
        self.state = authorizationResponse.state
        self.nextStep = authorizationResponse.nextStep
        self.customerInstructions = authorizationResponse.customerInstructions
    }

    init(tokenizationResponse: PONativeAlternativePaymentTokenizationResponseV2) {
        self.state = tokenizationResponse.state
        self.nextStep = tokenizationResponse.nextStep
        self.customerInstructions = tokenizationResponse.customerInstructions
    }
}

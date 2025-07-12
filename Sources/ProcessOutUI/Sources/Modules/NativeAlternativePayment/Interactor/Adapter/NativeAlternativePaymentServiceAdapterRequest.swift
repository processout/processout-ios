//
//  NativeAlternativePaymentServiceAdapterRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.06.2025.
//

@_spi(PO) import ProcessOut

struct NativeAlternativePaymentServiceAdapterRequest {

    init(
        flow: PONativeAlternativePaymentConfiguration.Flow,
        submitData: PONativeAlternativePaymentSubmitDataV2? = nil
    ) {
        self.flow = flow
        self.submitData = submitData
    }

    /// Payment flow.
    let flow: PONativeAlternativePaymentConfiguration.Flow

    /// Data to submit if any.
    let submitData: PONativeAlternativePaymentSubmitDataV2?
}

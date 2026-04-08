//
//  PONativeAlternativePaymentDeepLinkResolvedEvent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.03.2026.
//

@_spi(PO)
public struct PONativeAlternativePaymentDeepLinkResolvedEvent: POEventEmitterEvent {

    /// Native alternative payment URL resolution response.
    public let resolutionResponse: PONativeAlternativePaymentUrlResolutionResponseV2
}

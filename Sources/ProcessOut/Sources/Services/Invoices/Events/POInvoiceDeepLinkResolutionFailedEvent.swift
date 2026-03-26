//
//  POInvoiceDeepLinkResolutionFailedEvent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.03.2026.
//

import Foundation

@_spi(PO)
public struct POInvoiceDeepLinkResolutionFailedEvent: POEventEmitterEvent {

    /// Original deep link URL.
    public let url: URL

    /// Resolution error.
    public let error: POFailure
}

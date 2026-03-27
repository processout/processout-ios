//
//  PONativeAlternativePaymentDeepLinkResolutionFailedEvent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.03.2026.
//

import Foundation

@_spi(PO) // swiftlint:disable:next type_name
public struct PONativeAlternativePaymentDeepLinkResolutionFailedEvent: POEventEmitterEvent {

    /// Original deep link URL.
    public let url: URL

    /// Resolution error.
    public let error: POFailure
}

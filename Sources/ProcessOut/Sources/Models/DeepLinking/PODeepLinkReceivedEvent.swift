//
//  PODeepLinkReceivedEvent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

import Foundation

@_spi(PO)
public struct PODeepLinkReceivedEvent: POEventEmitterEvent {

    /// Url representing deep link or universal link.
    public let url: URL
}

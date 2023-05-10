//
//  DeepLinkReceivedEvent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

import Foundation

struct DeepLinkReceivedEvent: POEventEmitterEvent {

    /// Url representing deep link or universal link.
    let url: URL
}

//
//  PODeepLinkReceivedEvent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

import Foundation

package struct PODeepLinkReceivedEvent: POEventEmitterEvent {

    /// Url representing deep link or universal link.
    public let url: URL

    package init(url: URL) {
        self.url = url
    }
}

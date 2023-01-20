//
//  PORedirectCustomerActionContext.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.01.2023.
//

import Foundation

public struct PORedirectCustomerActionContext {

    /// Redirect url.
    public let url: URL

    /// Boolean value that indicates whether a given URL can be handled in headless mode, meaning
    /// without showing any UI for the user.
    public let isHeadlessModeAllowed: Bool

    /// Optional timeout interval.
    public let timeout: TimeInterval?
}

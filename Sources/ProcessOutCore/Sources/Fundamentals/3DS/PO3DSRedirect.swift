//
//  PO3DSRedirect.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.01.2023.
//

import Foundation

/// Holds information about 3DS redirect.
@available(iOS, introduced: 15, deprecated, message: "Redirects are handled internally.")
@_originallyDefinedIn(module: "ProcessOut", iOS 15)
public struct PO3DSRedirect: Hashable, Sendable {

    /// Redirect url.
    public let url: URL

    /// Boolean value that indicates whether a given URL can be handled in headless mode, meaning
    /// without showing any UI for the user.
    @available(*, deprecated)
    public let isHeadlessModeAllowed = false

    /// Optional timeout interval.
    public let timeout: TimeInterval?
}

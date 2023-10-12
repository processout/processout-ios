//
//  POBackport.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 04.10.2023.
//

import SwiftUI

/// Provides a convenient method for backporting API.
@_spi(PO) public struct POBackport<Wrapped> {

    /// The underlying content this backport represents.
    public let wrapped: Wrapped

    /// Initializes a new Backport for the specified content.
    /// - Parameter content: The content (type) that's being backported
    public init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }
}

extension View {

    /// Wraps a SwiftUI `View` that can be extended to provide backport functionality.
    @_spi(PO) public var backport: POBackport<Self> {
        .init(self)
    }
}

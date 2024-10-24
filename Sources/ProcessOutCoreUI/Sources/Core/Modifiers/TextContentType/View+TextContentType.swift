//
//  View+TextContentType.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.10.2023.
//

import SwiftUI

extension View {

    /// Sets the text content type for this view. In addition to calling the native counterpart,
    /// the implementation also exposes given type as an environment so works with `POTextField`.
    @_spi(PO)
    public func poTextContentType(_ type: UITextContentType?) -> some View {
        environment(\.poTextContentType, type).textContentType(type)
    }
}

extension EnvironmentValues {

    /// Text content type.
    @Entry
    var poTextContentType: UITextContentType?
}

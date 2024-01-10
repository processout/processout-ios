//
//  View+Background.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 29.11.2023.
//

import SwiftUI

extension POBackport where Wrapped: View {

    /// Isolates the geometry (e.g. position and size) of the view from its parent view.
    @available(iOS, deprecated: 17, message: "Use View/background(alignment:content:) directly.")
    public func background<V: View>(alignment: Alignment = .center, @ViewBuilder content: () -> V) -> some View {
        wrapped.background(content(), alignment: alignment)
    }
}

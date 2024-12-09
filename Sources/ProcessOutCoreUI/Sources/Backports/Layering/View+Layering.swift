//
//  View+Background.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 29.11.2023.
//

import SwiftUI

extension POBackport where Wrapped: View {

    /// Layers the given view behind this view.
    @available(iOS, deprecated: 17, message: "Use View/background(alignment:content:) directly.")
    public func background<V: View>(alignment: Alignment = .center, @ViewBuilder content: () -> V) -> some View {
        wrapped.background(content(), alignment: alignment)
    }

    /// Layers a secondary view in front of this view.
    @available(iOS, deprecated: 15, message: "Use View/overlay(alignment:content:) directly.")
    public func overlay<V: View>(alignment: Alignment = .center, @ViewBuilder content: () -> V) -> some View {
        wrapped.overlay(content(), alignment: alignment)
    }
}

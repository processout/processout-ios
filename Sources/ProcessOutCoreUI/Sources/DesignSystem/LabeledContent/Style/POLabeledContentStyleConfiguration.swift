//
//  POLabeledContentStyleConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.06.2025.
//

import SwiftUI

/// The properties of a labeled content instance.
@available(iOS 14, *)
public struct POLabeledContentStyleConfiguration {

    /// The label of the labeled content instance.
    public let label: AnyView

    /// The content of the labeled content instance.
    public let content: AnyView

    init(@ViewBuilder label: () -> some View, @ViewBuilder content: () -> some View) {
        self.label = AnyView(label())
        self.content = AnyView(content())
    }
}

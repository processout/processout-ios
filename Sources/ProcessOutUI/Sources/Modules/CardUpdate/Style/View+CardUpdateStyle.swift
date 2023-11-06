//
//  View+CardUpdateStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

import SwiftUI

extension View {

    /// Sets the style for card update views within this view.
    @available(iOS 14, *)
    public func cardUpdateStyle(_ style: POCardUpdateStyle) -> some View {
        environment(\.cardUpdateStyle, style)
    }
}

@available(iOS 14, *)
extension EnvironmentValues {

    var cardUpdateStyle: POCardUpdateStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = POCardUpdateStyle.default
    }
}

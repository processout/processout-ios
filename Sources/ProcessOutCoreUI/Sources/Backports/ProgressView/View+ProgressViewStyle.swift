//
//  View+ProgressViewStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.10.2023.
//

import SwiftUI

@available(iOS, deprecated: 14)
extension POBackport where Wrapped: View {

    /// Sets the style for progress views within this view.
    public func progressViewStyle<Style: POProgressViewStyle>(_ style: Style) -> some View {
        wrapped.environment(\.backportProgressViewStyle, AnyProgressViewStyle(erasing: style))
    }
}

@available(iOS, deprecated: 14)
extension EnvironmentValues {

    var backportProgressViewStyle: AnyProgressViewStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Properties

    private struct Key: EnvironmentKey {
        static let defaultValue = AnyProgressViewStyle(erasing: .circular())
    }
}

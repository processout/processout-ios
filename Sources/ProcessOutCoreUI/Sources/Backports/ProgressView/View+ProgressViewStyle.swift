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
    @_spi(PO) public func progressViewStyle<Style: POProgressViewStyle>(_ style: Style) -> some View {
        wrapped.environment(\.backportProgressViewStyle, .init(style))
    }
}

@available(iOS, deprecated: 14)
extension POBackport where Wrapped == Any {

    struct AnyProgressViewStyle: POProgressViewStyle {

        init<Style: POProgressViewStyle>(_ style: Style) {
            _makeBody = {
                AnyView(style.makeBody())
            }
        }

        func makeBody() -> some View {
            _makeBody()
        }

        // MARK: - Private Properties

        private let _makeBody: () -> AnyView
    }
}

@available(iOS, deprecated: 14)
extension EnvironmentValues {

    var backportProgressViewStyle: POBackport<Any>.AnyProgressViewStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Properties

    private struct Key: EnvironmentKey {
        static var defaultValue = POBackport<Any>.AnyProgressViewStyle(POCircularProgressViewStyle())
    }
}

//
//  View+InputStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 25.09.2023.
//

import SwiftUI

extension View {

    public func inputStyle(_ style: POInputStyle) -> some View {
        environment(\.inputStyle, style)
    }

    public func inputError(_ inError: Bool) -> some View {
        environment(\.inputError, inError)
    }
}

extension EnvironmentValues {

    var inputStyle: POInputStyle {
        get { self[StyleKey.self] }
        set { self[StyleKey.self] = newValue }
    }

    var inputError: Bool {
        get { self[ErrorKey.self] }
        set { self[ErrorKey.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct StyleKey: EnvironmentKey {
        static let defaultValue = POInputStyle.default()
    }

    private struct ErrorKey: EnvironmentKey {
        static let defaultValue = false
    }
}

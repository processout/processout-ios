//
//  View+InputStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 25.09.2023.
//

import SwiftUI

extension View {

    @_spi(PO) public func inputStyle(_ style: POInputStyle) -> some View {
        environment(\.inputStyle, style)
    }
}

extension EnvironmentValues {

    var inputStyle: POInputStyle {
        get { self[StyleKey.self] }
        set { self[StyleKey.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct StyleKey: EnvironmentKey {
        static let defaultValue = POInputStyle.default()
    }
}

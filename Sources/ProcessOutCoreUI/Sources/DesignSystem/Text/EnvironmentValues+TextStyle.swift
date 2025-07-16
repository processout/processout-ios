//
//  EnvironmentValues+TextStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.01.2025.
//

import SwiftUI

extension EnvironmentValues {

    var textStyle: POTextStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = POTextStyle(color: Color.Text.primary, typography: .Text.s14())
    }
}

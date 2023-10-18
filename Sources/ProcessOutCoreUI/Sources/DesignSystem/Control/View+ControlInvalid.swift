//
//  View+ControlInvalid.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 29.09.2023.
//

import SwiftUI

extension View {

    @_spi(PO) public func controlInvalid(_ isInvalid: Bool) -> some View {
        environment(\.isControlInvalid, isInvalid)
    }
}

extension EnvironmentValues {

    var isControlInvalid: Bool {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = false
    }
}

//
//  View+ScrollViewProxy.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 26.04.2024.
//

import SwiftUI

extension View {

    /// Sets the style for card tokenization views within this view.
    @_spi(PO)
    @available(iOS 14, *)
    public func scrollViewProxy(_ scrollView: ScrollViewProxy?) -> some View {
        // todo(andrii-vysotskyi): it seems that ScrollViewReader could be added directly so this may not be needed.
        environment(\.scrollViewProxy, scrollView)
    }
}

@available(iOS 14, *)
extension EnvironmentValues {

    @_spi(PO)
    public var scrollViewProxy: ScrollViewProxy? {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue: ScrollViewProxy? = nil
    }
}

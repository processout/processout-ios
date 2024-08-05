//
//  View+NativeAlternativePaymentSizeClass.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 05.08.2024.
//

import SwiftUI

extension View {

    /// Sets the size class for native APM layout.
    @available(iOS 14, *)
    func nativeAlternativePaymentSizeClass(_ sizeClass: NativeAlternativePaymentSizeClass) -> some View {
        environment(\.nativeAlternativePaymentSizeClass, sizeClass)
    }
}

@available(iOS 14, *)
extension EnvironmentValues {

    var nativeAlternativePaymentSizeClass: NativeAlternativePaymentSizeClass {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = NativeAlternativePaymentSizeClass.regular
    }
}

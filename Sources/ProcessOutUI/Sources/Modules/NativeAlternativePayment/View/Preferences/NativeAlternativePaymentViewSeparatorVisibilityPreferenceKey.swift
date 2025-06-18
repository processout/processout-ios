//
//  NativeAlternativePaymentViewSeparatorVisibilityPreferenceKey.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.06.2025.
//

import SwiftUI

// swiftlint:disable:next type_name
struct NativeAlternativePaymentViewSeparatorVisibilityPreferenceKey: PreferenceKey {

    /// Indicates whether separator is visible (represented by `true`) or hidden.
    static let defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

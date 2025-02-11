//
//  FocusableViewProxyPreferenceKey.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.01.2025.
//

import SwiftUI

struct FocusableViewProxyPreferenceKey: PreferenceKey {

    static func reduce(value: inout FocusableViewProxy, nextValue: () -> FocusableViewProxy) {
        value = nextValue()
    }

    static let defaultValue = FocusableViewProxy()
}

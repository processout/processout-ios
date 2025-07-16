//
//  View+OnChange.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 03.10.2023.
//

import SwiftUI
import Combine

extension POBackport where Wrapped: View {

    /// Adds a modifier for this view that fires an action when a specific value changes.
    @available(iOS, deprecated: 17)
    @ViewBuilder
    public func onChange<Value: Equatable>(of value: Value, perform action: @escaping () -> Void) -> some View {
        if #available(iOS 17, *) {
            wrapped.onChange(of: value, action)
        } else {
            wrapped.onChange(of: value) { _ in action() }
        }
    }
}

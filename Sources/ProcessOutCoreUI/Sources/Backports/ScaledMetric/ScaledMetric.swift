//
//  ScaledMetric.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 08.09.2023.
//

import SwiftUI

extension POBackport where Wrapped == Any {

    /// A dynamic property that scales a numeric value.
    @propertyWrapper
    struct ScaledMetric<Value: BinaryFloatingPoint>: DynamicProperty {

        /// Creates the scaled metric with an unscaled value and a text style to
        /// scale relative to.
        init(wrappedValue: Value, relativeTo textStyle: UIFont.TextStyle?) {
            baseValue = wrappedValue
            self.textStyle = textStyle
        }

        /// Creates the scaled metric with an unscaled value using the default
        /// scaling.
        init(wrappedValue: Value) {
            baseValue = wrappedValue
            textStyle = .body
        }

        /// The value scaled based on the current environment.
        var wrappedValue: Value {
            value(relativeTo: textStyle)
        }

        /// Returns value scaled based on the current environment to scale relative to.
        func value(relativeTo textStyle: UIFont.TextStyle?) -> Value {
            let metrics = textStyle.map(UIFontMetrics.init)
            let uiSizeCategory = UIContentSizeCategory(sizeCategory)
            let traits = UITraitCollection(preferredContentSizeCategory: uiSizeCategory)
            let scaledValue = metrics?.scaledValue(for: CGFloat(baseValue), compatibleWith: traits)
            return scaledValue.map(Value.init) ?? baseValue
        }

        // MARK: - Private Properties

        private let baseValue: Value
        private let textStyle: UIFont.TextStyle?

        @Environment(\.sizeCategory) private var sizeCategory
    }
}

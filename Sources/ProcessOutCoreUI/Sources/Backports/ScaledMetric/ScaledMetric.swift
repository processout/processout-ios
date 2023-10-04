//
//  ScaledMetricBackport.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 08.09.2023.
//

import SwiftUI

extension POBackport where Wrapped == Any {

    /// A dynamic property that scales a numeric value.
    @propertyWrapper
    struct ScaledMetric<Value: BinaryFloatingPoint>: DynamicProperty {

        /// The value scaled based on the current environment.
        var wrappedValue: Value {
            let uiSizeCategory = UIContentSizeCategory(sizeCategory)
            let traits = UITraitCollection(preferredContentSizeCategory: uiSizeCategory)
            let scaledValue = metrics?.scaledValue(for: CGFloat(baseValue), compatibleWith: traits)
            return scaledValue.map(Value.init) ?? baseValue
        }

        /// Creates the scaled metric with an unscaled value and a text style to
        /// scale relative to.
        init(wrappedValue: Value, relativeTo textStyle: UIFont.TextStyle?) {
            baseValue = wrappedValue
            metrics = textStyle.map(UIFontMetrics.init)
        }

        /// Creates the scaled metric with an unscaled value using the default
        /// scaling.
        init(wrappedValue: Value) {
            baseValue = wrappedValue
            metrics = UIFontMetrics(forTextStyle: .body)
        }

        // MARK: - Private Properties

        private let baseValue: Value
        private let metrics: UIFontMetrics?

        @Environment(\.sizeCategory) private var sizeCategory
    }
}

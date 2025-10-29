//
//  POLogMessage.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

package struct POLogMessage: ExpressibleByStringInterpolation, Sendable {

    let interpolation: POLogInterpolation

    /// Creates an instance from a string interpolation.
    package init(stringInterpolation: POLogInterpolation) {
        self.interpolation = stringInterpolation
    }

    /// Creates an instance initialised to the given string value.
    ///
    /// - Parameter value: The value of the new instance.
    package init(stringLiteral value: String) {
        var interpolation = POLogInterpolation(literalCapacity: value.count, interpolationCount: 0)
        interpolation.appendLiteral(value)
        self.interpolation = interpolation
    }
}

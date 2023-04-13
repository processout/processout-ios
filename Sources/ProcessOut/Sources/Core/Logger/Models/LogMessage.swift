//
//  LogMessage.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

struct LogMessage: ExpressibleByStringInterpolation {

    let interpolation: LogInterpolation

    /// Creates an instance from a string interpolation.
    init(stringInterpolation: LogInterpolation) {
        self.interpolation = stringInterpolation
    }

    /// Creates an instance initialized to the given string value.
    ///
    /// - Parameter value: The value of the new instance.
    init(stringLiteral value: String) {
        var interpolation = LogInterpolation(literalCapacity: value.count, interpolationCount: 0)
        interpolation.appendLiteral(value)
        self.interpolation = interpolation
    }
}

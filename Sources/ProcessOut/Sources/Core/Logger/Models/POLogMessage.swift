//
//  POLogMessage.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

@_spi(PO)
public struct POLogMessage: ExpressibleByStringInterpolation {

    public let interpolation: POLogInterpolation

    /// Creates an instance from a string interpolation.
    public init(stringInterpolation: POLogInterpolation) {
        self.interpolation = stringInterpolation
    }

    /// Creates an instance initialized to the given string value.
    ///
    /// - Parameter value: The value of the new instance.
    public init(stringLiteral value: String) {
        var interpolation = POLogInterpolation(literalCapacity: value.count, interpolationCount: 0)
        interpolation.appendLiteral(value)
        self.interpolation = interpolation
    }
}

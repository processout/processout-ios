//
//  POLogInterpolation.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

@_spi(PO) public struct POLogInterpolation: StringInterpolationProtocol {

    /// Privacy options for specifying privacy level of the interpolated expressions
    /// in the string interpolations passed to the log APIs.
    public enum Privacy {

        /// Sets the privacy level of an interpolated value to public.
        ///
        /// When the privacy level is public, the value will be displayed
        /// normally without any redaction in the logs.
        case `public`

        /// Sets the privacy level of an interpolated value to private.
        ///
        /// When the privacy level is private, the value will be redacted in the logs,
        /// subject to the privacy configuration of the logging system.
        case `private`
    }

    /// Interpolation's content.
    private(set) var value: String

    public mutating func appendLiteral(_ literal: String) {
        value.append(literal)
    }

    public mutating func appendInterpolation(_ value: String, privacy: Privacy = .public) {
        switch privacy {
        case .public:
            self.value.append(value)
        case .private:
            self.value.append("<private>")
        }
    }

    public mutating func appendInterpolation<Value: CustomStringConvertible>(
        _ value: Value, privacy: Privacy = .public
    ) {
        appendInterpolation(value.description, privacy: privacy)
    }

    public mutating func appendInterpolation(_ error: Error, privacy: Privacy = .public) {
        appendInterpolation(String(describing: error), privacy: privacy)
    }

    public mutating func appendInterpolation<Value>(_ value: Value, privacy: Privacy = .public) {
        appendInterpolation(String(describing: value), privacy: privacy)
    }

    public init(literalCapacity: Int, interpolationCount: Int) {
        value = String()
        value.reserveCapacity(literalCapacity)
    }
}

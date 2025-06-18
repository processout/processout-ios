//
//  RetryStrategy.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.10.2022.
//

import Foundation

@_spi(PO)
public struct RetryStrategy: Sendable {

    public struct Function: Sendable {

        func callAsFunction(retry: Int) -> TimeInterval {
            function(retry)
        }

        /// Actual function.
        let function: @Sendable (_ retry: Int) -> TimeInterval
    }

    /// Returns time interval for given retry or `nil` if no retry should occur.
    public func interval(for retry: Int) -> TimeInterval {
        let delay = min(function(retry: retry), maximum)
        return max(delay * TimeInterval.random(in: 0.5 ... 1), minimum) // Apple equal jitter
    }

    /// Function to use to calculate delay for given attempt number.
    public let function: Function

    /// Maximum number of retries.
    public let maximumRetries: Int

    /// Minimum delay value.
    public let minimum: TimeInterval

    /// Maximum delay value.
    public let maximum: TimeInterval

    /// Creates retry strategy.
    public init(
        function: Function,
        maximumRetries: Int = .max,
        minimum: TimeInterval = 0.1,
        maximum: TimeInterval = .greatestFiniteMagnitude
    ) {
        self.function = function
        self.maximumRetries = maximumRetries
        self.minimum = minimum
        self.maximum = maximum
    }
}

extension RetryStrategy.Function {

    public static func linear(interval: TimeInterval) -> Self {
        .init { _ in interval }
    }

    public static func exponential(interval: TimeInterval, rate: Double) -> Self {
        .init { interval * pow(rate, Double($0)) }
    }
}

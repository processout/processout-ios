//
//  RetryStrategy.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.10.2022.
//

import Foundation

struct RetryStrategy: Sendable {

    struct Function {

        func callAsFunction(retry: Int) -> TimeInterval {
            function(retry)
        }

        /// Actual function.
        let function: @Sendable (_ retry: Int) -> TimeInterval
    }

    /// Returns time interval for given retry or `nil` if no retry should occur.
    func interval(for retry: Int) -> TimeInterval {
        let delay = min(function(retry: retry), maximum)
        return max(delay * TimeInterval.random(in: 0.5 ... 1), minimum) // Apple equal jitter
    }

    /// Function to use to calculate delay for given attempt number.
    let function: Function

    /// Maximum number of retries.
    let maximumRetries: Int

    /// Minimum delay value.
    let minimum: TimeInterval

    /// Maximum delay value.
    let maximum: TimeInterval

    /// Creates retry strategy.
    init(
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

    static func exponential(interval: TimeInterval, rate: Double) -> Self {
        .init { interval * pow(rate, Double($0)) }
    }
}

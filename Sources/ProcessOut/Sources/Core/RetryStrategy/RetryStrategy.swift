//
//  RetryStrategy.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.10.2022.
//

import Foundation

struct RetryStrategy {

    /// Returns time interval to void for given retry.
    func interval(for retry: Int) -> TimeInterval {
        intervalFunction(retry)
    }

    /// Maximum number of retries.
    let maximumRetries: Int

    /// Function to use to calculate delay for given attempt number.
    let intervalFunction: (_ retry: Int) -> TimeInterval
}

extension RetryStrategy {

    static func linear(maximumRetries: Int, interval: TimeInterval) -> Self {
        .init(maximumRetries: maximumRetries) { _ in interval }
    }

    static func exponential(
        maximumRetries: Int,
        interval: TimeInterval,
        rate: Double,
        minimum: TimeInterval = 0,
        maximum: TimeInterval = .greatestFiniteMagnitude
    ) -> Self {
        RetryStrategy(maximumRetries: maximumRetries) { retry in
            let delay = interval * pow(rate, Double(retry))
            return max(min(delay, maximum), minimum)
        }
    }
}

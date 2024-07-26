//
//  LogLevel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

enum LogLevel: Int, Comparable, Sendable {

    /// The debug log level. Use this level to capture information that may be useful during development or while
    /// troubleshooting a specific problem.
    case debug

    /// The informational log level. Use this level to capture information that may be helpful, but not essential,
    /// for troubleshooting errors.
    case info

    /// Potentially harmful situations that do not necessarily require immediate attention but could
    /// indicate potential issues or unexpected behavior that might lead to more severe.
    case warn

    /// The error log level. Use this log level to report process-level errors.
    case error

    // MARK: - Comparable

    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

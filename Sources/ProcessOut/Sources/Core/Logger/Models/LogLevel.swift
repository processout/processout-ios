//
//  LogLevel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

enum LogLevel: Int {

    /// The debug log level. Use this level to capture information that may be useful during development or while
    /// troubleshooting a specific problem.
    case debug

    /// The informational log level. Use this level to capture information that may be helpful, but not essential,
    /// for troubleshooting errors.
    case info

    /// The error log level. Use this log level to report process-level errors.
    case error

    /// The fault log level. Use this level only to capture system-level or multi-process information when reporting
    /// system errors.
    case fault
}

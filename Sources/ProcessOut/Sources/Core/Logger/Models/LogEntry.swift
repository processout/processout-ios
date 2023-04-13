//
//  LogEntry.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

import Foundation

struct LogEntry {

    /// Logging level.
    let level: LogLevel

    /// Actual log message.
    let message: LogMessage

    /// Date associated with message.
    let timestamp: Date

    /// File name.
    let file: String

    /// Line number.
    let line: Int
}

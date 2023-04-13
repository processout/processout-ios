//
//  LogEntry.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

import Foundation

struct LogEntry {

    /// Logging level.
    let level: POLogLevel

    /// Actual log message.
    let message: POLogMessage

    /// Date associated with message.
    let timestamp: Date

    /// File name.
    let file: String

    /// Line number.
    let line: Int
}

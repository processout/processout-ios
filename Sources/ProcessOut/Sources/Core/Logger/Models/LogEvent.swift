//
//  LogEvent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

import Foundation

struct LogEvent {

    /// Logging level.
    let level: LogLevel

    /// Actual log message.
    let message: String

    /// The string that categorizes event.
    let category: String

    /// Date associated with message.
    let timestamp: Date

    /// File name.
    let file: String

    /// Line number.
    let line: Int

    /// Additional attributes.
    let additionalAttributes: [String: String]
}

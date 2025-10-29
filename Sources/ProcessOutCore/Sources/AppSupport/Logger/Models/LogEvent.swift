//
//  LogEvent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

import Foundation

package struct LogEvent: @unchecked Sendable {

    /// Logging level.
    package let level: LogLevel

    /// Actual log message.
    package let message: String

    /// The string that categorises event.
    package let category: String

    /// Date associated with message.
    package let timestamp: Date

    /// DSO handle.
    package let dso: UnsafeRawPointer?

    /// File name.
    package let file: String

    /// Line number.
    package let line: Int

    /// Additional attributes.
    package let additionalAttributes: [POLogAttributeKey: String]
}

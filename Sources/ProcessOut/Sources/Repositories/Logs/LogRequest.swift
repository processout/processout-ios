//
//  LogRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.05.2023.
//

import Foundation

struct LogRequest: Encodable {

    /// Log level.
    let level: String

    /// Event timestamp.
    let date: Date

    /// Actual log message.
    let message: String

    /// Event type. Could be module name, category etc.
    let eventType: String

    /// Arbitrary attributes.
    let attributes: [String: String]
}

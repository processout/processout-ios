//
//  SystemLoggerDestination.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

import Foundation
import os

final class SystemLoggerDestination: LoggerDestination, @unchecked Sendable {

    init(subsystem: String) {
        self.subsystem = subsystem
        lock = NSLock()
        logs = [:]
    }

    func log(event: LogEvent) {
        os_log(
            "%{public}@ %{public}@",
            dso: event.dso,
            log: osLog(category: event.category),
            type: convertToLogType(event.level),
            attributesDescription(event: event),
            event.message
        )
    }

    // MARK: - Private Properties

    private let subsystem: String
    private let lock: NSLock
    private var logs: [String: OSLog]

    // MARK: - Private Methods

    private func convertToLogType(_ level: LogLevel) -> OSLogType {
        switch level {
        case .info:
            return .info
        case .debug:
            return .debug
        case .warn:
            return .error
        case .error:
            return .error
        }
    }

    private func osLog(category: String) -> OSLog {
        let log = lock.withLock {
            if let log = logs[category] {
                return log
            }
            let log = OSLog(subsystem: subsystem, category: category)
            logs[category] = log
            return log
        }
        return log
    }

    private func attributesDescription(event: LogEvent) -> String {
        struct Attribute {
            let key, value: String
        }
        var attributes: [Attribute] = [
            Attribute(key: event.file, value: event.line.description)
        ]
        event.additionalAttributes.forEach { key, value in
            attributes.append(Attribute(key: key.rawValue, value: value))
        }
        return attributes.map { "[" + $0.key + ":" + $0.value + "]" } .joined()
    }
}

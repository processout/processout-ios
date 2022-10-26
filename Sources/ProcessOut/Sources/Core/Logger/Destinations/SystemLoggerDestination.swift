//
//  SystemLoggerDestination.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

import Foundation
import os

final class SystemLoggerDestination: LoggerDestination {

    func log(entry: LogEntry) {
        let logType = convertToLogType(entry.level)
        let message = entry.message.interpolation.value
        os_log("[%{public}@:%{public}ld] %{public}@", log: logger, type: logType, entry.file, entry.line, message)
    }

    // MARK: -

    private let logger: OSLog

    init(subsystem: String, category: String) {
        logger = OSLog(subsystem: subsystem, category: category)
    }

    // MARK: -

    private func convertToLogType(_ level: LogLevel) -> OSLogType {
        switch level {
        case .info:
            return .info
        case .debug:
            return .debug
        case .error:
            return .error
        case .fault:
            return .fault
        }
    }
}

//
//  DefaultLogsService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.05.2023.
//

import Foundation

final class DefaultLogsService: POService, LoggerDestination {

    init(repository: LogsRepository, minimumLevel: LogLevel) {
        self.repository = repository
        self.minimumLevel = minimumLevel
    }

    // MARK: - LoggerDestination

    func log(entry: LogEntry) {
        guard entry.level.rawValue >= minimumLevel.rawValue else {
            return
        }
        let attributes = [
            Constants.attributeFile: entry.file,
            Constants.attributeLine: entry.line.description
        ]
        let logEvent = LogEvent(
            level: string(from: entry.level),
            date: entry.timestamp,
            message: entry.message.interpolation.value,
            eventType: Constants.defaultEventType, // todo(andrii-vysotskyi): add proper even type
            attributes: attributes
        )
        repository.send(event: logEvent) { _ in /* Ignored */ }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let defaultEventType = "default"
        static let attributeFile = "File"
        static let attributeLine = "Line"
    }

    // MARK: - Private Properties

    private let repository: LogsRepository
    private let minimumLevel: LogLevel

    // MARK: - Private Methods

    private func string(from level: LogLevel) -> String {
        let strings: [LogLevel: String] = [
            .debug: "debug", .info: "info", .error: "error", .fault: "critical"
        ]
        return strings[level]! // swiftlint:disable:this force_unwrapping
    }
}

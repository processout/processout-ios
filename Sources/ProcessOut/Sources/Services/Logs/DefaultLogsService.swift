//
//  DefaultLogsService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.05.2023.
//

import Foundation

/// This service is thread safe.
final class DefaultLogsService: POService, LoggerDestination {

    init(repository: LogsRepository, minimumLevel: LogLevel) {
        self.repository = repository
        self.minimumLevel = minimumLevel
    }

    // MARK: - LoggerDestination

    func log(event: LogEvent) {
        guard event.level.rawValue >= minimumLevel.rawValue else {
            return
        }
        var attributes = [
            Constants.attributeFile: event.file, Constants.attributeLine: event.line.description
        ]
        event.additionalAttributes.forEach { key, value in
            attributes[key] = value
        }
        let request = LogRequest(
            level: string(from: event.level),
            date: event.timestamp,
            message: event.message,
            eventType: event.category,
            attributes: attributes
        )
        repository.send(request: request)
    }

    // MARK: - Private Nested Types

    private enum Constants {
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

//
//  POLogger.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

import Foundation

/// An object for writing interpolated string messages to the processout logging system.
public struct POLogger {

    init(destinations: [LoggerDestination] = [], category: String, minimumLevel: LogLevel = .debug) {
        self.destinations = destinations
        self.category = category
        self.minimumLevel = minimumLevel
        self.attributes = [:]
        lock = NSLock()
    }

    /// Add, change, or remove a logging attribute.
    subscript(attributeKey attributeKey: String) -> String? {
        get {
            lock.withLock { attributes[attributeKey] }
        }
        set {
            lock.withLock { attributes[attributeKey] = newValue }
        }
    }

    let category: String

    /// Logs a message at the `debug` level.
    func debug(_ message: LogMessage, attributes: [String: String] = [:], file: String = #file, line: Int = #line) {
        log(level: .debug, message, attributes: attributes, file: file, line: line)
    }

    /// Logs a message at the `info` level.
    func info(_ message: LogMessage, attributes: [String: String] = [:], file: String = #file, line: Int = #line) {
        log(level: .info, message, attributes: attributes, file: file, line: line)
    }

    /// Logs a message at the `error` level.
    func error(_ message: LogMessage, attributes: [String: String] = [:], file: String = #file, line: Int = #line) {
        log(level: .error, message, attributes: attributes, file: file, line: line)
    }

    /// Logs a message at the `fault` level.
    func fault(_ message: LogMessage, attributes: [String: String] = [:], file: String = #file, line: Int = #line) {
        log(level: .fault, message, attributes: attributes, file: file, line: line)
    }

    // MARK: - Private Properties

    private let destinations: [LoggerDestination]
    private let minimumLevel: LogLevel
    private let lock: NSLock
    private var attributes: [String: String]

    // MARK: - Private Methods

    /// Records a message at the specified log level. Use this method when you need to adjust the log level
    /// dynamically for a given message.
    ///
    /// - Parameters:
    ///   - level: The log level at which to store the message. This value determines the severity of the message and
    ///   whether the system persists it to disk. You may specify a constant or variable for this parameter.
    ///   - message: the message you want to add to the logs.
    ///   - attributes: additional attributes to log alongside primary logger attributes.
    private func log(
        level: LogLevel,
        _ message: LogMessage,
        attributes additionalAttributes: [String: String] = [:],
        file: String = #file,
        line: Int = #line
    ) {
        guard level >= minimumLevel else {
            return
        }
        var attributes = lock.withLock { self.attributes }
        additionalAttributes.forEach { key, value in
            attributes[key] = value
        }
        let entry = LogEvent(
            level: level,
            message: message.interpolation.value,
            category: category,
            timestamp: Date(),
            // swiftlint:disable:next legacy_objc_type
            file: NSString(string: NSString(string: file).deletingPathExtension).lastPathComponent,
            line: line,
            additionalAttributes: attributes
        )
        destinations.forEach { $0.log(event: entry) }
    }
}

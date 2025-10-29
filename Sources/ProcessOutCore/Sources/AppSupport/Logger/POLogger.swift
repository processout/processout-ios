//
//  POLogger.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

import Foundation

/// An object for writing interpolated string messages to the processout logging system.
package struct POLogger: @unchecked Sendable {

    package init(destinations: [LoggerDestination] = [], category: String, minimumLevel: LogLevel = .debug) {
        self.destinations = destinations
        self.category = category
        self.storage = .init(minimumLevel: minimumLevel)
        self.attributes = [:]
        lock = NSLock()
    }

    /// Logger category.
    let category: String

    /// Replaces current minimum logging level.
    package func replace(minimumLevel: LogLevel) {
        lock.withLock { self.storage.minimumLevel = minimumLevel }
    }

    /// Add, change, or remove a logging attribute.
    package subscript(attributeKey attributeKey: POLogAttributeKey) -> String? {
        get {
            lock.withLock { attributes[attributeKey] }
        }
        set {
            lock.withLock { attributes[attributeKey] = newValue }
        }
    }

    /// Logs a message at the `debug` level.
    package func debug(
        _ message: @autoclosure () -> POLogMessage,
        attributes: @autoclosure () -> [POLogAttributeKey: String] = [:],
        dso: UnsafeRawPointer? = #dsohandle,
        file: String = #fileID,
        line: Int = #line
    ) {
        log(level: .debug, message, attributes: attributes, dso: dso, file: file, line: line)
    }

    /// Logs a message at the `info` level.
    package func info(
        _ message: @autoclosure () -> POLogMessage,
        attributes: @autoclosure () -> [POLogAttributeKey: String] = [:],
        dso: UnsafeRawPointer? = #dsohandle,
        file: String = #fileID,
        line: Int = #line
    ) {
        log(level: .info, message, attributes: attributes, dso: dso, file: file, line: line)
    }

    /// Logs a message at the `warn` level.
    package func warn(
        _ message: @autoclosure () -> POLogMessage,
        attributes: @autoclosure () -> [POLogAttributeKey: String] = [:],
        dso: UnsafeRawPointer? = #dsohandle,
        file: String = #fileID,
        line: Int = #line
    ) {
        log(level: .warn, message, attributes: attributes, dso: dso, file: file, line: line)
    }

    /// Logs a message at the `error` level.
    package func error(
        _ message: @autoclosure () -> POLogMessage,
        attributes: @autoclosure () -> [POLogAttributeKey: String] = [:],
        dso: UnsafeRawPointer? = #dsohandle,
        file: String = #fileID,
        line: Int = #line
    ) {
        log(level: .error, message, attributes: attributes, dso: dso, file: file, line: line)
    }

    // MARK: - Private Properties

    private let destinations: [LoggerDestination]
    private let lock: NSLock
    private let storage: MutableStorage
    private var attributes: [POLogAttributeKey: String]

    // MARK: - Private Methods

    /// Records a message at the specified log level. Use this method when you need to adjust the log level
    /// dynamically for a given message.
    ///
    /// - Parameters:
    ///   - level: The log level at which to store the message. This value determines the severity of the message and
    ///   whether the system persists it to disk. You may specify a constant or variable for this parameter.
    ///   - message: the message you want to add to the logs.
    ///   - attributes: additional attributes to log alongside primary logger attributes.
    private func log( // swiftlint:disable:this function_parameter_count
        level: LogLevel,
        _ message: () -> POLogMessage,
        attributes additionalAttributes: () -> [POLogAttributeKey: String],
        dso: UnsafeRawPointer?,
        file: String,
        line: Int
    ) {
        let attributes: [POLogAttributeKey: String]? = lock.withLock {
            guard level >= storage.minimumLevel else {
                return nil
            }
            var attributes = self.attributes
            additionalAttributes().forEach { key, value in
                attributes[key] = value
            }
            return attributes
        }
        guard let attributes else {
            return
        }
        let entry = LogEvent(
            level: level,
            message: message().interpolation.value,
            category: category,
            timestamp: Date(),
            dso: dso,
            // swiftlint:disable:next legacy_objc_type
            file: NSString(string: NSString(string: file).deletingPathExtension).lastPathComponent,
            line: line,
            additionalAttributes: attributes
        )
        destinations.forEach { $0.log(event: entry) }
    }
}

private final class MutableStorage {

    init(minimumLevel: LogLevel) {
        self.minimumLevel = minimumLevel
    }

    var minimumLevel: LogLevel
}

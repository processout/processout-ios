//
//  POLogger.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

import Foundation

/// An object for writing interpolated string messages to the processout logging system.
@_spi(PO)
public struct POLogger {

    init(destinations: [LoggerDestination] = [], category: String, minimumLevel: @escaping () -> LogLevel) {
        self.destinations = destinations
        self.category = category
        self.minimumLevel = minimumLevel
        self.attributes = [:]
        lock = NSLock()
    }

    init(destinations: [LoggerDestination] = [], category: String) {
        self.init(destinations: destinations, category: category) { .debug }
    }

    /// Add, change, or remove a logging attribute.
    @_spi(PO)
    public subscript(attributeKey attributeKey: POLogAttributeKey) -> String? {
        get {
            lock.withLock { attributes[attributeKey] }
        }
        set {
            lock.withLock { attributes[attributeKey] = newValue }
        }
    }

    let category: String

    /// Logs a message at the `debug` level.
    @_spi(PO) public func debug(
        _ message: @autoclosure () -> POLogMessage,
        attributes: @autoclosure () -> [POLogAttributeKey: String] = [:],
        dso: UnsafeRawPointer? = #dsohandle,
        file: String = #fileID,
        line: Int = #line
    ) {
        log(level: .debug, message, attributes: attributes, dso: dso, file: file, line: line)
    }

    /// Logs a message at the `info` level.
    @_spi(PO) public func info(
        _ message: @autoclosure () -> POLogMessage,
        attributes: @autoclosure () -> [POLogAttributeKey: String] = [:],
        dso: UnsafeRawPointer? = #dsohandle,
        file: String = #fileID,
        line: Int = #line
    ) {
        log(level: .info, message, attributes: attributes, dso: dso, file: file, line: line)
    }

    /// Logs a message at the `warn` level.
    @_spi(PO) public func warn(
        _ message: @autoclosure () -> POLogMessage,
        attributes: @autoclosure () -> [POLogAttributeKey: String] = [:],
        dso: UnsafeRawPointer? = #dsohandle,
        file: String = #fileID,
        line: Int = #line
    ) {
        log(level: .warn, message, attributes: attributes, dso: dso, file: file, line: line)
    }

    /// Logs a message at the `error` level.
    @_spi(PO) public func error(
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
    private let minimumLevel: () -> LogLevel
    private let lock: NSLock
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
        guard level >= minimumLevel() else {
            return
        }
        var attributes = lock.withLock { self.attributes }
        additionalAttributes().forEach { key, value in
            attributes[key] = value
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

//
//  Logger+Extension.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

extension Logger {

    /// Logger with a UI subsystem.
    static let ui: Logger = createLogger(for: "UI") // swiftlint:disable:this identifier_name

    /// Logger with a services subsystem.
    static let services: Logger = createLogger(for: "Services")

    /// Logger with a connectors subsystem.
    static let connectors: Logger = createLogger(for: "Connectors")

    private static func createLogger(for category: String) -> Logger {
        let destinations: [LoggerDestination] = [
            SystemLoggerDestination(subsystem: "com.processout.processout-ios", category: category)
        ]
        return Logger(destinations: destinations)
    }
}

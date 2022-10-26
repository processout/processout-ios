//
//  Logger+Extension.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

extension Logger {

    /// Logger with a connectors subsystem.
    static let connectors: Logger = createLogger(for: "Connectors")

    private static func createLogger(for category: String) -> Logger {
        let destinations: [LoggerDestination] = [
            SystemLoggerDestination(subsystem: "com.processout", category: category)
        ]
        return Logger(destinations: destinations)
    }
}

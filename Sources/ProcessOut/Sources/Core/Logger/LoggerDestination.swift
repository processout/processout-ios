//
//  LoggerDestination.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

protocol LoggerDestination {

    /// Logs given message.
    func log(entry: LogEntry)
}

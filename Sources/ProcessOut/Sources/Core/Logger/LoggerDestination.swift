//
//  LoggerDestination.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

protocol LoggerDestination {

    /// Logs given event.
    func log(event: LogEvent)
}

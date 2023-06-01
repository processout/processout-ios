//
//  LogsRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.05.2023.
//

protocol LogsRepository: PORepository {

    /// Sends given log event.
    func send(event: LogEvent)
}

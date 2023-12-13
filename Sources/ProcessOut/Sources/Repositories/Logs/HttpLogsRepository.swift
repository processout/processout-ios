//
//  HttpLogsRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.05.2023.
//

import Foundation

final class HttpLogsRepository: LogsRepository {

    init(connector: HttpConnector) {
        self.connector = connector
    }

    // MARK: - LogsRepository

    func send(request: LogRequest) {
        let httpRequest = HttpConnectorRequest<VoidCodable>.post(path: "/logs", body: request)
        Task {
            _ = try? await connector.execute(request: httpRequest)
        }
    }

    // MARK: - Private Properties

    private let connector: HttpConnector
}

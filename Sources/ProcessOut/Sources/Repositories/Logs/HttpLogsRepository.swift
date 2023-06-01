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
        connector.execute(request: httpRequest) { _ in }
    }

    // MARK: - Private Properties

    private let connector: HttpConnector
}

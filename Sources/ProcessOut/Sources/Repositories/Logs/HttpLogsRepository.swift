//
//  HttpLogsRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.05.2023.
//

import Foundation

final class HttpLogsRepository: LogsRepository {

    init(connector: HttpConnector, failureMapper: HttpConnectorFailureMapper) {
        self.connector = connector
        self.failureMapper = failureMapper
    }

    // MARK: - LogsRepository

    func send(event: LogEvent, completion: @escaping (Result<Void, POFailure>) -> Void) {
        let httpRequest = HttpConnectorRequest<VoidCodable>.post(path: "/logs", body: event)
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.map { _ in () }.mapError(failureMapper.failure))
        }
    }

    // MARK: - Private Properties

    private let connector: HttpConnector
    private let failureMapper: HttpConnectorFailureMapper
}

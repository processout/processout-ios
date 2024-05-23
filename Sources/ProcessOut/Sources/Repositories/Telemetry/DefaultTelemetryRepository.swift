//
//  DefaultTelemetryRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.04.2024.
//

final class DefaultTelemetryRepository: TelemetryRepository {

    init(connector: HttpConnector) {
        self.connector = connector
    }

    // MARK: - TelemetryRepository

    func submit(telemetry: Telemetry) async throws {
        let request = HttpConnectorRequest<VoidCodable>.post(path: "/telemetry", body: telemetry)
        _ = try await connector.execute(request: request)
    }

    // MARK: - Private Properties

    private let connector: HttpConnector
}

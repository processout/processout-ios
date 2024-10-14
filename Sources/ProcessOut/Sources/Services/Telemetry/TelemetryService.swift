//
//  TelemetryService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.10.2024.
//

protocol TelemetryService: POService, LoggerDestination {

    /// Replaces existing configuration.
    func replace(configuration: TelemetryServiceConfiguration)
}

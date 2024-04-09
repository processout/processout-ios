//
//  TelemetryRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.04.2024.
//

import Foundation

protocol TelemetryRepository {

    /// Submits telemetery.
    func submit(telemetry: Telemetry) async throws
}

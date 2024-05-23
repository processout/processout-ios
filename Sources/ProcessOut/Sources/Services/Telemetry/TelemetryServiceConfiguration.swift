//
//  TelemetryServiceConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 09.04.2024.
//

struct TelemetryServiceConfiguration {

    /// Indicates whether telemetry is enabled.
    let isTelemetryEnabled: Bool

    /// Application version.
    let applicationVersion: String?

    /// Host application name.
    let applicationName: String?
}

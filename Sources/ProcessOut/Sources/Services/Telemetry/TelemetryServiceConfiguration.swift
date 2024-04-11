//
//  TelemetryServiceConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 09.04.2024.
//

struct TelemetryServiceConfiguration {

    /// Indicates whether telemetry is enabled.
    let isTelemetryEnabled: Bool

    /// Boolean value indicating whther this is a debug build.
    let isDebug: Bool

    /// Application version.
    let applicationVersion: String?

    /// Host application name.
    let applicationName: String?
}

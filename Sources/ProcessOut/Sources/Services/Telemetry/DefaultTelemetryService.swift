//
//  DefaultTelemetryService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.04.2024.
//

import Foundation

final class DefaultTelemetryService: POService, LoggerDestination {

    init(
        configuration: @escaping () -> TelemetryServiceConfiguration,
        repository: TelemetryRepository,
        deviceMetadataProvider: DeviceMetadataProvider
    ) {
        self.configuration = configuration
        self.repository = repository
        self.deviceMetadataProvider = deviceMetadataProvider
        initBatcher()
    }

    // MARK: - LoggerDestination

    func log(event: LogEvent) {
        // todo(andrii-vysotskyi): ignore logs if debugger is attached
        let configuration = self.configuration()
        guard configuration.isTelemetryEnabled, event.level.rawValue >= configuration.minimumLevel.rawValue else {
            return
        }
        var attributes = [
            "file": event.file,
            "line": event.line.description,
            "category": event.category
        ]
        event.additionalAttributes.forEach { key, value in
            attributes[key] = value
        }
        let telemetryEvent = Telemetry.Event(
            timestamp: event.timestamp,
            level: string(from: event.level),
            attributes: attributes,
            message: event.message
        )
        batcher.submit(task: telemetryEvent)
    }

    // MARK: - Private Properties

    private let repository: TelemetryRepository
    private let deviceMetadataProvider: DeviceMetadataProvider
    private let configuration: () -> TelemetryServiceConfiguration

    private var batcher: Batcher<Telemetry.Event>! // swiftlint:disable:this implicitly_unwrapped_optional

    // MARK: - Private Methods

    private func initBatcher() {
        let batcher = Batcher<Telemetry.Event> { [weak self] events in
            guard let self else {
                return true // self no longer exists, return true to "drop" pending events
            }
            let telemetry = Telemetry(metadata: await telemetryMetadata(), events: events)
            do {
                try await repository.submit(telemetry: telemetry)
            } catch {
                return false
            }
            return true
        }
        self.batcher = batcher
    }

    private func telemetryMetadata() async -> Telemetry.Metadata {
        let application: Telemetry.ApplicationMetadata = {
            let configuration = self.configuration()
            return .init(name: configuration.applicationVersion, version: configuration.applicationVersion)
        }()
        let device: Telemetry.DeviceMetadata = await {
            let metadata = await deviceMetadataProvider.deviceMetadata
            return .init(language: metadata.appLanguage, model: metadata.model, timeZone: metadata.appTimeZoneOffset)
        }()
        return Telemetry.Metadata(application: application, device: device)
    }

    private func string(from level: LogLevel) -> String {
        let strings: [LogLevel: String] = [
            .debug: "debug", .info: "info", .error: "error", .fault: "critical"
        ]
        return strings[level]! // swiftlint:disable:this force_unwrapping
    }
}

//
//  DefaultTelemetryService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.04.2024.
//

import Foundation

final class DefaultTelemetryService: TelemetryService {

    init(
        configuration: TelemetryServiceConfiguration,
        repository: TelemetryRepository,
        deviceMetadataProvider: DeviceMetadataProvider
    ) {
        self.configuration = .init(wrappedValue: configuration)
        self.repository = repository
        self.deviceMetadataProvider = deviceMetadataProvider
        initBatcher()
    }

    // MARK: - TelemetryService

    func replace(configuration: TelemetryServiceConfiguration) {
        self.configuration.withLock { $0 = configuration }
    }

    // MARK: - LoggerDestination

    func log(event: LogEvent) {
        guard event.level.rawValue >= LogLevel.warn.rawValue else {
            return
        }
        var attributes = [
            "File": event.file,
            "Line": event.line.description,
            "Category": event.category
        ]
        event.additionalAttributes.forEach { key, value in
            let excludedAttributes: Set<POLogAttributeKey> = [
                .gatewayConfigurationId, .cardId, .invoiceId, .customerId, .customerTokenId
            ]
            guard !excludedAttributes.contains(key) else {
                return // Excluded attributes are encoded directly to event
            }
            attributes[key.rawValue] = value
        }
        let telemetryEvent = Telemetry.Event(
            timestamp: event.timestamp,
            level: string(from: event.level),
            gatewayConfigurationId: event.additionalAttributes[.gatewayConfigurationId],
            cardId: event.additionalAttributes[.cardId],
            invoiceId: event.additionalAttributes[.invoiceId],
            customerId: event.additionalAttributes[.customerId],
            customerTokenId: event.additionalAttributes[.customerTokenId],
            attributes: attributes,
            message: event.message
        )
        batcher.submit(task: telemetryEvent)
    }

    // MARK: - Private Properties

    private let repository: TelemetryRepository
    private let deviceMetadataProvider: DeviceMetadataProvider
    private let configuration: POUnfairlyLocked<TelemetryServiceConfiguration>

    // swiftlint:disable:next implicitly_unwrapped_optional
    private nonisolated(unsafe) var batcher: Batcher<Telemetry.Event>!

    // MARK: - Private Methods

    private func initBatcher() {
        let batcher = Batcher<Telemetry.Event>(executionInterval: 3) { [weak self] events in
            guard let self else {
                return true // Self no longer exists, return true to "drop" pending events
            }
            let configuration = self.configuration.wrappedValue
            guard configuration.isTelemetryEnabled else {
                return true // Events shouldn't be submitted, return true to "drop" pending
            }
            let telemetry = Telemetry(metadata: await telemetryMetadata(configuration: configuration), events: events)
            do {
                try await repository.submit(telemetry: telemetry)
            } catch {
                return false
            }
            return true
        }
        self.batcher = batcher
    }

    private func telemetryMetadata(configuration: TelemetryServiceConfiguration) async -> Telemetry.Metadata {
        let application = Telemetry.ApplicationMetadata(
            name: configuration.applicationVersion, version: configuration.applicationVersion
        )
        let device: Telemetry.DeviceMetadata = await {
            let metadata = await deviceMetadataProvider.deviceMetadata
            return .init(language: metadata.appLanguage, model: metadata.model, timeZone: metadata.appTimeZoneOffset)
        }()
        return Telemetry.Metadata(application: application, device: device)
    }

    private func string(from level: LogLevel) -> String {
        let strings: [LogLevel: String] = [
            .debug: "debug", .info: "info", .warn: "warn", .error: "error"
        ]
        return strings[level]! // swiftlint:disable:this force_unwrapping
    }
}

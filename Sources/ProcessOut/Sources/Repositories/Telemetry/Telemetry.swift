//
//  Telemetry.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.04.2024.
//

import Foundation

struct Telemetry: Encodable {

    struct ApplicationMetadata: Encodable {

        /// Host application name.
        let name: String?

        /// Application version.
        let version: String?
    }

    struct DeviceMetadata: Encodable {

        /// Device system language.
        let language: String

        /// Device model.
        let model: String?

        /// Time zone offset in minutes.
        let timeZone: Int
    }

    struct Metadata: Encodable {

        /// App metadata.
        let application: ApplicationMetadata

        /// Device metadata.
        let device: DeviceMetadata
    }

    struct Event: Encodable {

        /// Event timestamp.
        let timestamp: Date

        /// Event level.
        let level: String

        /// Gateway configuration ID.
        let gatewayConfigurationId: String?

        /// Card ID.
        let cardId: String?

        /// Invoice ID.
        let invoiceId: String?

        /// Customer ID.
        let customerId: String?

        /// Customer token ID.
        let customerTokenId: String?

        /// Event attributes.
        let attributes: [String: String]

        /// Event message.
        let message: String
    }

    /// Telemetry metadata.
    let metadata: Metadata

    /// Events.
    let events: [Event]
}

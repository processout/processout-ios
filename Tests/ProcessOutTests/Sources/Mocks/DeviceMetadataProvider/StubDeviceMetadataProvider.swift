//
//  StubDeviceMetadataProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.04.2023.
//

@testable import ProcessOut

struct StubDeviceMetadataProvider: DeviceMetadataProvider {

    var deviceMetadata: DeviceMetadata {
        DeviceMetadata(
            id: "id",
            installationId: nil,
            systemVersion: "4",
            model: "model",
            appLanguage: "en",
            appScreenWidth: 1,
            appScreenHeight: 2,
            appTimeZoneOffset: 3,
            channel: "test"
        )
    }
}

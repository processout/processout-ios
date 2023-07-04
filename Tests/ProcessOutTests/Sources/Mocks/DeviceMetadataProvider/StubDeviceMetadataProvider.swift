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
            id: .init(value: ""),
            installationId: .init(value: nil),
            systemVersion: .init(value: ""),
            appLanguage: "en",
            appScreenWidth: 1,
            appScreenHeight: 2,
            appTimeZoneOffset: 3,
            channel: "test"
        )
    }
}

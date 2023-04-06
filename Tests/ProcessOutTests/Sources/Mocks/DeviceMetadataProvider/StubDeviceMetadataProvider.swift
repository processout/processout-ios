//
//  StubDeviceMetadataProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.04.2023.
//

@testable import ProcessOut

struct StubDeviceMetadataProvider: DeviceMetadataProviderType {

    var deviceMetadata: DeviceMetadata {
        DeviceMetadata(appLanguage: "en", appScreenWidth: 1, appScreenHeight: 2, appTimeZoneOffset: 3, channel: "test")
    }
}

//
//  MockPhoneNumberMetadataProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.05.2023.
//

@testable import ProcessOut

final class MockPhoneNumberMetadataProvider: POPhoneNumberMetadataProvider {

    var metadataCallsCount = 0
    var metadata: POPhoneNumberMetadata?

    func metadata(for countryCode: String) -> POPhoneNumberMetadata? {
        metadataCallsCount += 1
        return metadata
    }
}

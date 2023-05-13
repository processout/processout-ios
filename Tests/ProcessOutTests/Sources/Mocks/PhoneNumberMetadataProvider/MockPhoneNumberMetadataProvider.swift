//
//  MockPhoneNumberMetadataProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.05.2023.
//

@testable import ProcessOut

final class MockPhoneNumberMetadataProvider: PhoneNumberMetadataProvider {

    var metadataCallsCount = 0
    var metadata: PhoneNumberMetadata?

    func metadata(for countryCode: String) -> PhoneNumberMetadata? {
        metadataCallsCount += 1
        return metadata
    }
}

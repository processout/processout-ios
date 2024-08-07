//
//  MockPhoneNumberMetadataProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.05.2023.
//

@testable import ProcessOutUI

final class MockPhoneNumberMetadataProvider: PhoneNumberMetadataProvider {

    var metadataCallsCount = 0
    var metadata: POPhoneNumberMetadata?

    func metadata(for countryCode: String) -> PhoneNumberMetadata? {
        metadataCallsCount += 1
        return metadata
    }
}

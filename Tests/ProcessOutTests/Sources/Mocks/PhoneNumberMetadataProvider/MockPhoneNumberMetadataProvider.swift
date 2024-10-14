//
//  MockPhoneNumberMetadataProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.05.2023.
//

@testable @_spi(PO) import ProcessOut

final class MockPhoneNumberMetadataProvider: POPhoneNumberMetadataProvider {

    var metadataCallsCount: Int {
        lock.withLock { _metadataCallsCount }
    }

    var metadata: POPhoneNumberMetadata? {
        get { lock.withLock { _metadata } }
        set { lock.withLock { _metadata = newValue } }
    }

    func metadata(for countryCode: String) -> POPhoneNumberMetadata? {
        lock.withLock {
            _metadataCallsCount += 1
            return metadata
        }
    }

    // MARK: - Private Properties

    private let lock = POUnfairlyLocked()

    private nonisolated(unsafe) var _metadataCallsCount = 0
    private nonisolated(unsafe) var _metadata: POPhoneNumberMetadata?
}

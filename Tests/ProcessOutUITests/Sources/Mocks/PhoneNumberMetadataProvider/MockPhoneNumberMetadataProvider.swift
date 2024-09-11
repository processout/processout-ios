//
//  MockPhoneNumberMetadataProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.05.2023.
//

@_spi(PO) import ProcessOut
@testable import ProcessOutUI

final class MockPhoneNumberMetadataProvider: PhoneNumberMetadataProvider, Sendable {

    var metadataCallsCount: Int {
        lock.withLock { _metadataCallsCount }
    }

    var metadata: PhoneNumberMetadata? {
        get { lock.withLock { _metadata } }
        set { lock.withLock { _metadata = newValue } }
    }

    func metadata(for countryCode: String) -> PhoneNumberMetadata? {
        lock.withLock {
            _metadataCallsCount += 1
            return _metadata
        }
    }

    // MARK: - Private Properties

    private let lock = POUnfairlyLocked()

    private nonisolated(unsafe) var _metadataCallsCount = 0
    private nonisolated(unsafe) var _metadata: PhoneNumberMetadata?
}

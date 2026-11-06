//
//  DefaultDeviceMetadataProviderTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 06.11.2026.
//

import UIKit
import Testing
@testable @_spi(PO) import ProcessOut

@MainActor
struct DefaultDeviceMetadataProviderTests {

    @Test(arguments: [(3600, -60), (-18000, 300), (19800, -330), (0, 0)])
    func deviceMetadata_returnsUtcMinusLocalTimezoneOffset(secondsFromGmt: Int, expectedOffset: Int) async throws {
        // Given
        let timeZone = try #require(TimeZone(secondsFromGMT: secondsFromGmt))
        let sut = createProvider(timeZone: timeZone)

        // When
        let metadata = await sut.deviceMetadata

        // Then
        #expect(metadata.appTimezoneOffset == expectedOffset)
    }

    @Test
    func deviceMetadata_whenEncodedWithSnakeCase_usesAppTimezoneOffsetKey() async throws {
        // Given
        let timeZone = try #require(TimeZone(secondsFromGMT: 3600))
        let sut = createProvider(timeZone: timeZone)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        // When
        let data = try encoder.encode(await sut.deviceMetadata)

        // Then
        let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(json["app_timezone_offset"] as? Int == -60)
        #expect(json["app_time_zone_offset"] == nil)
    }

    // MARK: - Private Methods

    private func createProvider(timeZone: TimeZone) -> DefaultDeviceMetadataProvider {
        DefaultDeviceMetadataProvider(
            screen: .main,
            device: .current,
            bundle: .main,
            keychain: Keychain(service: "com.processout.tests"),
            timeZone: timeZone
        )
    }
}

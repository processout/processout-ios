//
//  GatewayConfigurationsRepositoryTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 10.07.2023.
//

import Foundation
import XCTest
@testable import ProcessOut

final class GatewayConfigurationsRepositoryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        ProcessOut.configure(configuration: .init(projectId: Constants.projectId), force: true)
        sut = ProcessOut.shared.gatewayConfigurations
    }

    // MARK: - Tests

    func test_all_returnsConfigurations() async throws {
        // Given
        let request = POAllGatewayConfigurationsRequest(filter: nil, paginationOptions: nil)

        // When
        let response = try await sut.all(request: request)

        // Then
        XCTAssertFalse(response.gatewayConfigurations.isEmpty)
    }

    func test_find_returnsConfiguration() async throws {
        // Given
        let configurationId = "gway_conf_VJEp8Y6ZCqiiwkSa3JioJrwdVM3bVgJd"
        let request = POFindGatewayConfigurationRequest(id: configurationId)

        // When
        let configuration = try await sut.find(request: request)

        // Then
        XCTAssertEqual(configurationId, configuration.id)
    }

    func test_find_whenExpandsGateway_returnsConfigurationWithGateway() async throws {
        // Given
        let request = POFindGatewayConfigurationRequest(
            id: "gway_conf_VJEp8Y6ZCqiiwkSa3JioJrwdVM3bVgJd", expands: .gateway
        )

        // When
        let configuration = try await sut.find(request: request)

        // Then
        XCTAssertNotNil(configuration.gateway)
    }

    // MARK: - Private Properties

    private var sut: POGatewayConfigurationsRepository!
}

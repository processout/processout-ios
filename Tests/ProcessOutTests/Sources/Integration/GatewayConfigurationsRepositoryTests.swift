//
//  GatewayConfigurationsRepositoryTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 10.07.2023.
//

import Foundation
import Testing
@testable import ProcessOut

struct GatewayConfigurationsRepositoryTests {

    init() async {
        let processOut = await ProcessOut(configuration: .init(projectId: Constants.projectId))
        sut = processOut.gatewayConfigurations
    }

    // MARK: - Tests

    @Test
    func all_returnsConfigurations() async throws {
        // Given
        let request = POAllGatewayConfigurationsRequest(filter: nil, paginationOptions: nil)

        // When
        let response = try await sut.all(request: request)

        // Then
        #expect(!response.gatewayConfigurations.isEmpty)
    }

    @Test
    func find_returnsConfiguration() async throws {
        // Given
        let configurationId = "gway_conf_VJEp8Y6ZCqiiwkSa3JioJrwdVM3bVgJd"
        let request = POFindGatewayConfigurationRequest(id: configurationId)

        // When
        let configuration = try await sut.find(request: request)

        // Then
        #expect(configurationId == configuration.id)
    }

    @Test
    func find_whenExpandsGateway_returnsConfigurationWithGateway() async throws {
        // Given
        let request = POFindGatewayConfigurationRequest(
            id: "gway_conf_VJEp8Y6ZCqiiwkSa3JioJrwdVM3bVgJd", expands: .gateway
        )

        // When
        let configuration = try await sut.find(request: request)

        // Then
        #expect(configuration.gateway != nil)
    }

    // MARK: - Private Properties

    private let sut: POGatewayConfigurationsRepository
}

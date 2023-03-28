//
//  CardsRepositoryTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 28.03.2023.
//

// swiftlint:disable function_body_length

import Foundation
import XCTest
@testable import ProcessOut

final class CardsRepositoryTestsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let logger = POLogger()
        let failureMapper = HttpConnectorFailureMapper(logger: logger)
        sut = CardsRepository(connector: createHttpConnector(), failureMapper: failureMapper)
    }

    override func tearDown() {
        super.tearDown()
        MockUrlProtocol.removeRegistrations()
    }

    // MARK: - Tests

    func test_tokenizeRequest_returnsCard() async throws {
        // Given
        MockUrlProtocol.register(path: "/cards") { request in
            XCTAssertEqual(request.httpMethod, "POST")
            if let queryParameters = request.url?.queryParameters {
                XCTAssertEqual(queryParameters.isEmpty, true)
            }
            let response = try MockUrlProtocolResponseBuilder()
                .with(url: request.url)
                .with(contentsOf: "CardsRepositoryTokenize200", extension: "json")
                .build()
            return response
        }

        // When
        let request = POCardTokenizationRequest(number: "4242424242424242", expMonth: 3, expYear: 2030)
        let card = try await sut.tokenize(request: request)

        // Then
        let expectedCard = POCard(
            id: "card_JKpuFW87EVxGMcslln0psUbf4rCEmD8F",
            projectId: "proj_2d05627c8b10391927c6f3dc8dfd8834",
            scheme: "visa",
            coScheme: "carte bancaire",
            preferredScheme: nil,
            type: "credit",
            bankName: nil,
            brand: "classic", //
            category: "consumer",
            iin: "42424242",
            last4Digits: "4242",
            fingerprint: "2d05627c8b10391927c6f3dc8dfd883445b7f9f002cd934f45c6a9d242159eea",
            expMonth: 3,
            expYear: 2030,
            cvcCheck: "unavailable",
            avsCheck: "unavailable",
            tokenType: nil,
            name: "John Smith",
            address1: nil,
            address2: nil,
            city: nil,
            state: nil,
            countryCode: "GB",
            zip: "10000",
            expiresSoon: false,
            metadata: [:],
            sandbox: true,
            createdAt: Date(timeIntervalSince1970: 1680009558.1),
            updateType: nil
        )
        XCTAssertEqual(card, expectedCard)
    }

    func test_tokenizeRequest_whenNumberIsInvalid_throwsError() async throws {
        // Given
        MockUrlProtocol.register(path: "/cards") { request in
            XCTAssertEqual(request.httpMethod, "POST")
            if let queryParameters = request.url?.queryParameters {
                XCTAssertEqual(queryParameters.isEmpty, true)
            }
            let response = try MockUrlProtocolResponseBuilder()
                .with(url: request.url)
                .with(contentsOf: "CardsRepositoryTokenize400", extension: "json")
                .build()
            return response
        }

        // When
        do {
            let request = POCardTokenizationRequest(number: "", expMonth: 3, expYear: 2030)
            _ = try await sut.tokenize(request: request)
        } catch let failure as POFailure {
            // Then
            XCTAssertEqual(failure.code, POFailure.Code.unknown(rawValue: "card.invalid-number"))
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        static let baseUrl = URL(string: "https://example.com")! // swiftlint:disable:this force_unwrapping
    }

    // MARK: - Private Properties

    private var sut: CardsRepository! // swiftlint:disable:this implicitly_unwrapped_optional

    // MARK: - Private Methods

    // todo(andrii-vysotskyi): make this reusable from other test cases
    private func createHttpConnector() -> HttpConnectorType {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockUrlProtocol.self]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dateFormat
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        let connector = HttpConnector(
            configuration: .init(baseUrl: Constants.baseUrl, projectId: "", privateKey: "", version: ""),
            sessionConfiguration: sessionConfiguration,
            decoder: decoder,
            encoder: encoder,
            // todo(andrii-vysotskyi): replace with mock or stub to avoid unpredictable dynamic data
            deviceMetadataProvider: DeviceMetadataProvider(screen: .main, bundle: .main),
            logger: POLogger()
        )
        return connector
    }
}

//
//  HttpCardsRepositoryTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 28.03.2023.
//

import Foundation
import XCTest
@testable @_spi(PO) import ProcessOut

final class HttpCardsRepositoryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // todo(andrii-vysotskyi): use mocks or stubs for failure mapper and device metadata provider
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockUrlProtocol.self]
        let logger = POLogger()
        let connector = ProcessOutHttpConnectorBuilder()
            .with(configuration: .init(baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: ""))
            .with(retryStrategy: nil)
            .with(sessionConfiguration: sessionConfiguration)
            .with(logger: logger)
            .build()
        sut = HttpCardsRepository(
            connector: connector, failureMapper: DefaultHttpConnectorFailureMapper(logger: logger)
        )
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

        do {
            // When
            let request = POCardTokenizationRequest(number: "", expMonth: 3, expYear: 2030)
            _ = try await sut.tokenize(request: request)

            // Then
            XCTFail("Tokenization is expected to fail.")
        } catch {
            XCTAssertTrue(error is POFailure)
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let baseUrl = URL(string: "https://example.com")!
    }

    // MARK: - Private Properties

    private var sut: HttpCardsRepository!
}

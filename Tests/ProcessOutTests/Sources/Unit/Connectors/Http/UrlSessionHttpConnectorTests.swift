//
//  UrlSessionHttpConnectorTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.04.2023.
//

import Foundation
import XCTest
@testable import ProcessOut

final class UrlSessionHttpConnectorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // todo(andrii-vysotskyi): use mock or stub for failure mapper
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockUrlProtocol.self]
        let logger = POLogger()
        let connector = ProcessOutHttpConnectorBuilder()
            .with(configuration: .init(baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: ""))
            .with(retryStrategy: nil)
            .with(sessionConfiguration: sessionConfiguration)
            .with(logger: logger)
            .build()
        sut = CardsRepository(connector: connector, failureMapper: HttpConnectorFailureMapper(logger: logger))
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let baseUrl = URL(string: "https://example.com")! // swiftlint:disable:this force_unwrapping
    }

    // MARK: - Private Properties

    private var sut: UrlSessionHttpConnector! // swiftlint:disable:this implicitly_unwrapped_optional
}

//    func test_decode_whenSuccessIsNotPresent_fails() throws {
//        // Given
//        let decoder = JSONDecoder()
//        let data = Data("{}".utf8)
//
//        // Then
//        XCTAssertThrowsError(try decoder.decode(HttpConnectorResponse<Int>.self, from: data))
//    }
//
//    func test_decode_whenSuccessIsTrueAndValueNotPresent_fails() throws {
//        // Given
//        let decoder = JSONDecoder()
//        let data = Data(#"{"success": true}"#.utf8)
//
//        // Then
//        XCTAssertThrowsError(try decoder.decode(HttpConnectorResponse<Int>.self, from: data))
//    }
//
//    func test_decode_whenSuccessIsFalseAndFailureNotPresent_fails() throws {
//        // Given
//        let decoder = JSONDecoder()
//        let data = Data(#"{"success": false}"#.utf8)
//
//        // Then
//        XCTAssertThrowsError(try decoder.decode(HttpConnectorResponse<Int>.self, from: data))
//    }
//
//    func test_decode_whenSuccessIsTrueAndValuePresent_succeeds() throws {
//        // Given
//        let decoder = JSONDecoder()
//        let data = Data(#"{"success": false, "value": 1}"#.utf8)
//
//        // When
//        let response = try decoder.decode(HttpConnectorResponse<[String: Int]>.self, from: data)
//
//        // Then
//        switch response {
//        case .success(let value):
//            XCTAssertEqual(value, [""])
//        case .failure:
//            XCTFail("Unexpected failure")
//        }
//    }
// }

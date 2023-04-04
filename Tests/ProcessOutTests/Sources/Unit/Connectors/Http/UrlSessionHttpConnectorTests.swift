//
//  UrlSessionHttpConnectorTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.04.2023.
//

import Foundation

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

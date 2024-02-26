//
//  ThreeDSRedirectSafariViewModelDelegateTests.swift
//  ProcessOutUITests
//
//  Created by Andrii Vysotskyi on 15.01.2024.
//

import XCTest
@_spi(PO) @testable import ProcessOut
@testable import ProcessOutUI
import Vision

final class ThreeDSRedirectSafariViewModelDelegateTests: XCTestCase {

//    func test_complete_whenTokenIsEmpty_succeeds() throws {
//        var result: Result<String, POFailure>!
//
//        // Given
//        let sut = ThreeDSRedirectSafariViewModelDelegate { result = $0 }
//
//        // When
//        let url = URL(string: #"test://return"#)!
//        try sut.complete(with: url)
//
//        // Then
//        XCTAssertTrue(try result.get().isEmpty)
//    }
//
//    func test_complete_whenTokenIsSet_completesWithIt() throws {
//        var result: Result<String, POFailure>!
//
//        // Given
//        let sut = ThreeDSRedirectSafariViewModelDelegate { result = $0 }
//
//        // When
//        let url = URL(string: #"test://return?token=test"#)!
//        try sut.complete(with: url)
//
//        // Then
//        XCTAssertEqual(try result.get(), "test")
//    }

    func test_temp() {
        let sut = PaymentCardNumberRecognizer(regexProvider: .shared)

        let recognition = "4242 4242 4242 4242"

        let number = sut.process(recognitions: [recognition])
        XCTAssertEqual(number, "4242424242424242")
    }
}

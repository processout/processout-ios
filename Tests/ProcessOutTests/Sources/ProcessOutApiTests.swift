//
//  ProcessOutApiTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.10.2022.
//

import XCTest
@testable import ProcessOut

final class ProcessOutApiTests: XCTestCase {

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssert(!ProcessOutApi.version.isEmpty)
    }
}

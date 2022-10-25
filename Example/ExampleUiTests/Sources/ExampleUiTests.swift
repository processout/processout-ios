//
//  ExampleUiTests.swift
//  ExampleUiTests
//
//  Created by Andrii Vysotskyi on 21.10.2022.
//

import XCTest

final class ExampleUiTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

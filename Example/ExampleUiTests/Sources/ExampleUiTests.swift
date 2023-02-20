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
        app = createApplication()
        app.launch()
    }

    func test_blikPayment_whenCodeIsValid_succeeds() throws {
        // Open native alternative payment methods
        app.cells["features.native-alternative-payment"].firstMatch.tap()

        // Initiate payment
        let paymentMethodElement = app
            .staticTexts
            .containing(NSPredicate(format: "label CONTAINS[c] 'BLIK'"))
            .firstMatch
        XCTAssertTrue(paymentMethodElement.waitForExistence(timeout: 1))
        paymentMethodElement.tap()

        // Enter amount
        let amountTextField = app.textFields["authorization-amount.amount"]
        XCTAssertTrue(amountTextField.waitForExistence(timeout: 1))
        amountTextField.tap()
        amountTextField.typeText("100")

        // Enter currency
        let currencyTextField = app.textFields["authorization-amount.currency"]
        currencyTextField.tap()
        currencyTextField.typeText("PLN")

        // Submit amount and currency
        app.buttons["authorization-amount.confirm"].tap()

        // Enter valid code
        let codeTextView = app.textViews["native-alternative-payment.code-input"].firstMatch
        XCTAssertTrue(codeTextView.waitForExistence(timeout: 10))
        codeTextView.typeText("777222")

        // Submit input
        app.buttons["native-alternative-payment.primary-button"].firstMatch.tap()

        // Wait for pending action screen
        let pendingStaticText = app
            .staticTexts["native-alternative-payment.non-captured.description"]
            .firstMatch
        XCTAssertTrue(pendingStaticText.waitForExistence(timeout: 10))

        // Wait for success screen
        let successStaticText = app
            .staticTexts["native-alternative-payment.captured.description"]
            .firstMatch
        XCTAssertTrue(successStaticText.waitForExistence(timeout: 30))
    }

    // MARK: - Private Properties

    private var app: XCUIApplication! // swiftlint:disable:this implicitly_unwrapped_optional

    // MARK: - Private Methods

    private func createApplication() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)"]
        app.launchArguments += ["-AppleLocale", "en_US"]
        return app
    }
}

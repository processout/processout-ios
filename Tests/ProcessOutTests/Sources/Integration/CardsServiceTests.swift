//
//  CardsServiceTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 27.06.2023.
//

import Foundation
import XCTest
@_spi(PO) import ProcessOut

final class CardsServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let configuration = ProcessOutConfiguration.test(
            projectId: Constants.projectId,
            privateKey: Constants.projectPrivateKey,
            apiBaseUrl: URL(string: Constants.apiBaseUrl)!,
            checkoutBaseUrl: URL(string: Constants.checkoutBaseUrl)!
        )
        ProcessOut.configure(configuration: configuration)
        sut = ProcessOut.shared.cards
    }

    func test_issuerInformation() async throws {
        // When
        let information = try await sut.issuerInformation(iin: "400012")

        // Then
        XCTAssertEqual(information.bankName, "UNITED CITIZENS BANK OF SOUTHERN KENTUCKY")
        XCTAssertEqual(information.brand, "visa business")
        XCTAssertEqual(information.category, "business")
        XCTAssertEqual(information.scheme, "visa")
        XCTAssertEqual(information.type, "debit")
    }

    func test_issuerInformation_whenIinIsTooShort_throws() async {
        do {
            // When
            _ = try await sut.issuerInformation(iin: "4")
        } catch {
            return
        }

        // Then
        XCTFail("IIN with length less than 6 symbols should be invalid")
    }

    // MARK: - Tests

    private var sut: POCardsService!
}

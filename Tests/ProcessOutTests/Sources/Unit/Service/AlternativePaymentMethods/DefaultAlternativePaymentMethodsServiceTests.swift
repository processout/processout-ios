//
//  DefaultAlternativePaymentMethodsServiceTests.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 28/10/2022.
//

import Foundation
import XCTest
@testable @_spi(PO) import ProcessOut

final class DefaultAlternativePaymentMethodsServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        sut = DefaultAlternativePaymentsService(
            configuration: {
                .init(projectId: "proj_test", baseUrl: URL(string: "https://example.com")!)
            },
            webSession: MockWebAuthenticationSession(),
            logger: .stub
        )
    }

    func test_alternativePaymentMethodUrl_authorizationWithAdditionalData_succeeds() throws {
        let request = POAlternativePaymentAuthorizationRequest(
            invoiceId: "iv_test",
            gatewayConfigurationId: "gway_conf_test",
            additionalData: ["field1": "test", "field2": "test2"]
        )

        // When
        let url = try sut.url(for: request)

        // Then
        let expectedUrls = [
            // swiftlint:disable line_length
            "https://example.com/proj_test/iv_test/redirect/gway_conf_test?additional_data%5Bfield1%5D=test&additional_data%5Bfield2%5D=test2",
            "https://example.com/proj_test/iv_test/redirect/gway_conf_test?additional_data%5Bfield2%5D=test2&additional_data%5Bfield1%5D=test"
            // swiftlint:enable line_length
        ]
        let isUrlExpected = expectedUrls.contains { $0 == url.absoluteString }
        XCTAssertTrue(isUrlExpected)
    }

    func test_alternativePaymentMethodUrl_tokenization_succeeds() throws {
        let request = POAlternativePaymentTokenizationRequest(
            customerId: "cust_test",
            tokenId: "tok_test",
            gatewayConfigurationId: "gway_conf_test"
        )

        // When
        let url = try sut.url(for: request)

        // Then
        let expectedUrl = "https://example.com/proj_test/cust_test/tok_test/redirect/gway_conf_test"
        XCTAssertEqual(url.absoluteString, expectedUrl)
    }

    func test_alternativePaymentMethodUrl_authorizationWithToken_succeeds() throws {
        let request = POAlternativePaymentAuthorizationRequest(
            invoiceId: "iv_test", gatewayConfigurationId: "gway_conf_test", tokenId: "tok_test"
        )

        // When
        let url = try sut.url(for: request)

        // Then
        let expectedUrl = "https://example.com/proj_test/iv_test/redirect/gway_conf_test/tokenized/tok_test"
        XCTAssertEqual(url.absoluteString, expectedUrl)
    }

    // MARK: - Private Properties

    private var sut: DefaultAlternativePaymentsService!
}

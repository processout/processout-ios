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
        let baseUrl = URL(string: "https://example.com")!
        sut = DefaultAlternativePaymentMethodsService(projectId: "proj_test", baseUrl: baseUrl, logger: .stub)
    }

    func test_alternativePaymentMethodUrl_withAdditionalData_succeeds() throws {
        let request = POAlternativePaymentMethodRequest(
            invoiceId: "iv_test",
            gatewayConfigurationId: "gway_conf_test",
            additionalData: ["field1": "test", "field2": "test2"]
        )

        // When
        let url = sut.alternativePaymentMethodUrl(request: request)

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

    func test_alternativePaymentMethodUrl_withToken_succeeds() throws {
        let request = POAlternativePaymentMethodRequest(
            invoiceId: "iv_test",
            gatewayConfigurationId: "gway_conf_test",
            customerId: "cust_test",
            tokenId: "tok_test"
        )

        // When
        let url = sut.alternativePaymentMethodUrl(request: request)

        // Then
        let expectedUrl = "https://example.com/proj_test/cust_test/tok_test/redirect/gway_conf_test"
        XCTAssertEqual(url.absoluteString, expectedUrl)
    }

    func test_alternativePaymentMethodResponse_withOnlyGatewayToken_succeeds() throws {
        let result: POAlternativePaymentMethodResponse? = try sut.alternativePaymentMethodResponse(
            url: URL(string: "https://processout.return?token=gway_req_test")!
        )

        XCTAssertEqual(result?.gatewayToken, "gway_req_test")
    }

    func test_alternativePaymentMethodResponse_withCustomerToken_succeeds() throws {
        let result: POAlternativePaymentMethodResponse? = try sut.alternativePaymentMethodResponse(
            url: URL(string: "https://processout.return?token=gway_req_test&token_id=tok_test&customer_id=cust_test")!
        )

        XCTAssertEqual(result?.gatewayToken, "gway_req_test")
        XCTAssertEqual(result?.tokenId, "tok_test")
        XCTAssertEqual(result?.customerId, "cust_test")
    }

    private var sut: DefaultAlternativePaymentMethodsService!
}

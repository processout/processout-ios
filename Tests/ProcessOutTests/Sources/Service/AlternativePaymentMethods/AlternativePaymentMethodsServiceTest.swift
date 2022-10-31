//
//  AlternativePaymentMethodsServiceTest.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 28/10/2022.
//

import Foundation

import XCTest
@testable import ProcessOut

final class AlternativePaymentMethodsServiceTest: XCTestCase {
    override func setUp() {
        super.setUp()
        apmService = AlternativePaymentMethodsService(
            projectId: "proj_test",
            // swiftlint:disable:next force_unwrapping
            baseUrl: URL(string: "https://checkout.processout.ninja")!
        )
    }

    func test_alternativePaymentMethodUrl_withAdditionalData_succeeds() throws {
        let apmRequest = POAlternativePaymentMethodRequest(
            invoiceId: "iv_test",
            gatewayConfigurationId: "gway_conf_test",
            additionalData: ["field1": "test", "field2": "test2"]
        )

        let url = apmService.alternativePaymentMethodUrl(request: apmRequest)

        let expectedUrl = "https://checkout.processout.ninja/proj_test/" +
            "iv_test/redirect/gway_conf_test?additional_data%5Bfield1%5D=test&additional_data%5Bfield2%5D=test2"
        XCTAssertEqual(url.absoluteString, expectedUrl)
    }

    func test_alternativePaymentMethodUrl_withToken_succeeds() throws {
        let apmRequest = POAlternativePaymentMethodRequest(
            invoiceId: "iv_test",
            gatewayConfigurationId: "gway_conf_test",
            customerId: "cust_test",
            tokenId: "tok_test"
        )

        let url = apmService.alternativePaymentMethodUrl(request: apmRequest)

        let expectedUrl = "https://checkout.processout.ninja/proj_test/cust_test/tok_test/redirect/gway_conf_test"
        XCTAssertEqual(url.absoluteString, expectedUrl)
    }

    func test_alternativePaymentMethodResponse_withOnlyGatewayToken_succeeds() throws {
        // This is a dummy URL, not the actual one the API will return
        let returnUrl = "https://processout.return?token=gway_req_test"

        let result: POAlternativePaymentMethodResponse? = try apmService.alternativePaymentMethodResponse(
            url: URL(string: returnUrl)! // swiftlint:disable:this force_unwrapping
        )

        XCTAssertEqual(result?.gatewayToken, "gway_req_test")
    }

    func test_alternativePaymentMethodResponse_withCustomerToken_succeeds() throws {
        // This is a dummy URL, not the actual one the API will return
        let returnUrl = "https://processout.return?token=gway_req_test" +
        "&token_id=tok_test&customer_id=cust_test"

        let result: POAlternativePaymentMethodResponse? = try apmService.alternativePaymentMethodResponse(
            url: URL(string: returnUrl)! // swiftlint:disable:this force_unwrapping
        )

        XCTAssertEqual(result?.gatewayToken, "gway_req_test")
        XCTAssertEqual(result?.tokenId, "tok_test")
        XCTAssertEqual(result?.customerId, "cust_test")
    }

    private var apmService: AlternativePaymentMethodsService! // swiftlint:disable:this implicitly_unwrapped_optional
}

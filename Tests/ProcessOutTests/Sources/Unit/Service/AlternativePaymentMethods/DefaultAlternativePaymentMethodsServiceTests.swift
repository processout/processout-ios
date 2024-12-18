//
//  DefaultAlternativePaymentMethodsServiceTests.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 28/10/2022.
//

import Foundation
import Testing
@testable @_spi(PO) import ProcessOut

struct DefaultAlternativePaymentMethodsServiceTests {

    init() {
        let configuration = POAlternativePaymentsServiceConfiguration(
            projectId: "proj_test", baseUrl: URL(string: "https://example.com")!
        )
        let webSession = MockWebAuthenticationSession()
        sut = .init(configuration: configuration, webSession: webSession, logger: .stub)
    }

    @Test
    func alternativePaymentMethodUrl_authorizationWithAdditionalData_succeeds() throws {
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
        #expect(isUrlExpected)
    }

    @Test
    func alternativePaymentMethodUrl_tokenization_succeeds() throws {
        let request = POAlternativePaymentTokenizationRequest(
            customerId: "cust_test",
            customerTokenId: "tok_test",
            gatewayConfigurationId: "gway_conf_test"
        )

        // When
        let url = try sut.url(for: request)

        // Then
        #expect(url.absoluteString == "https://example.com/proj_test/cust_test/tok_test/redirect/gway_conf_test")
    }

    @Test
    func alternativePaymentMethodUrl_authorizationWithToken_succeeds() throws {
        let request = POAlternativePaymentAuthorizationRequest(
            invoiceId: "iv_test", gatewayConfigurationId: "gway_conf_test", customerTokenId: "tok_test"
        )

        // When
        let url = try sut.url(for: request)

        // Then
        let expectedUrl = "https://example.com/proj_test/iv_test/redirect/gway_conf_test/tokenized/tok_test"
        #expect(url.absoluteString == expectedUrl)
    }

    @available(*, deprecated)
    @Test
    func alternativePaymentMethodResponse_withOnlyGatewayToken_succeeds() throws {
        // When
        let result = try sut.alternativePaymentMethodResponse(
            url: URL(string: "https://processout.return?token=gway_req_test")!
        )

        // Then
        #expect(result.gatewayToken == "gway_req_test")
    }

    @available(*, deprecated)
    @Test
    func alternativePaymentMethodResponse_withCustomerToken_succeeds() throws {
        // When
        let result = try sut.alternativePaymentMethodResponse(
            url: URL(string: "https://processout.return?token=gway_req_test&token_id=tok_test&customer_id=cust_test")!
        )

        // Then
        #expect(
            result.gatewayToken == "gway_req_test" && result.tokenId == "tok_test" && result.customerId == "cust_test"
        )
    }

    @available(*, deprecated)
    @Test
    func alternativePaymentMethodResponse_whenTokenIsNotSet_succeeds() throws {
        // When
        let url = URL(string: "test://return")!
        let result = try sut.alternativePaymentMethodResponse(url: url)

        // Then
        #expect(result.gatewayToken.isEmpty)
    }

    // MARK: - Private Properties

    private let sut: DefaultAlternativePaymentsService
}

//
//  AlternativePaymentMethodWebViewControllerDelegate.swift
//  Example
//
//  Created by Andrii Vysotskyi on 07.11.2022.
//

import WebKit

final class AlternativePaymentMethodWebViewControllerDelegate: WebViewControllerDelegate {

    init(
        alternativePaymentMethodsService: POAlternativePaymentMethodsServiceType,
        request: POAlternativePaymentMethodRequest
    ) {
        self.alternativePaymentMethodsService = alternativePaymentMethodsService
        self.request = request
    }

    // MARK: - WebViewControllerDelegate

    var url: URL {
        alternativePaymentMethodsService.alternativePaymentMethodUrl(request: request)
    }

    func mapToSuccessValue(url: URL) throws -> POAlternativePaymentMethodResponse {
        try alternativePaymentMethodsService.alternativePaymentMethodResponse(url: url)
    }

    // MARK: - Private Properties

    private let alternativePaymentMethodsService: POAlternativePaymentMethodsServiceType
    private let request: POAlternativePaymentMethodRequest
}

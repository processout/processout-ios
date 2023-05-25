//
//  WebViewControllerDelegateAlternativePaymentMethod.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.11.2022.
//

import WebKit

final class WebViewControllerDelegateAlternativePaymentMethod: WebViewControllerDelegate {

    init(
        alternativePaymentMethodsService: POAlternativePaymentMethodsService,
        request: POAlternativePaymentMethodRequest,
        completion: @escaping (Result<POAlternativePaymentMethodResponse, POFailure>) -> Void
    ) {
        self.alternativePaymentMethodsService = alternativePaymentMethodsService
        self.request = request
        self.completion = completion
    }

    // MARK: - WebViewControllerDelegate

    var url: URL {
        alternativePaymentMethodsService.alternativePaymentMethodUrl(request: request)
    }

    func complete(with url: URL) throws {
        let response = try alternativePaymentMethodsService.alternativePaymentMethodResponse(url: url)
        completion(.success(response))
    }

    func complete(with failure: POFailure) {
        completion(.failure(failure))
    }

    // MARK: - Private Properties

    private let alternativePaymentMethodsService: POAlternativePaymentMethodsService
    private let request: POAlternativePaymentMethodRequest
    private let completion: (Result<POAlternativePaymentMethodResponse, POFailure>) -> Void
}

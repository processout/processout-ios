//
//  AlternativePaymentMethodSafariViewModelDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 07.11.2022.
//

import Foundation
import ProcessOut

final class AlternativePaymentMethodSafariViewModelDelegate: DefaultSafariViewModelDelegate {

    typealias Completion = (Result<POAlternativePaymentMethodResponse, POFailure>) -> Void

    init(alternativePaymentMethodsService: POAlternativePaymentMethodsService, completion: @escaping Completion) {
        self.alternativePaymentMethodsService = alternativePaymentMethodsService
        self.completion = completion
    }

    // MARK: - DefaultSafariViewModelDelegate

    func complete(with url: URL) throws {
        let response = try alternativePaymentMethodsService.alternativePaymentMethodResponse(url: url)
        completion(.success(response))
    }

    func complete(with failure: POFailure) {
        completion(.failure(failure))
    }

    // MARK: - Private Properties

    private let alternativePaymentMethodsService: POAlternativePaymentMethodsService
    private let completion: Completion
}

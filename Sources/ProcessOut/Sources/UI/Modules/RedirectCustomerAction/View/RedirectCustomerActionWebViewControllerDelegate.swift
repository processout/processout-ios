//
//  RedirectCustomerActionWebViewControllerDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.11.2022.
//

import WebKit

final class RedirectCustomerActionWebViewControllerDelegate: WebViewControllerDelegate {

    init(url: URL, completion: @escaping (Result<String, POFailure>) -> Void) {
        self.url = url
        self.completion = completion
    }

    // MARK: - WebViewControllerDelegate

    let url: URL

    func complete(with url: URL) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let token = components.queryItems?.first(where: { $0.name == "token" }) else {
            throw POFailure(message: nil, code: .internal(.mobile), underlyingError: nil)
        }
        let tokenValue = token.value ?? ""
        completion(.success(tokenValue))
    }

    func complete(with failure: POFailure) {
        completion(.failure(failure))
    }

    // MARK: - Private Properties

    private let completion: (Result<String, POFailure>) -> Void
}

//
//  CustomerActionWebViewControllerDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.11.2022.
//

import WebKit

final class CustomerActionWebViewControllerDelegate: WebViewControllerDelegate {

    init(url: URL) {
        self.url = url
    }

    // MARK: -

    func mapToSuccessValue(url: URL) throws -> String {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let token = components.queryItems?.first(where: { $0.name == "token" }) else {
            throw PORepositoryFailure(message: nil, code: .internal, underlyingError: nil)
        }
        return token.value ?? ""
    }

    let url: URL
}

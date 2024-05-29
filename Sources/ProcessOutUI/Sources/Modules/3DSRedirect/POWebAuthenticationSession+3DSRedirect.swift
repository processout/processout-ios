//
//  POWebAuthenticationSession+3DSRedirect.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.05.2024.
//

import Foundation
import ProcessOut

extension POWebAuthenticationSession {

    /// Creates POWebAuthenticationSession that is able to handle 3DS redirects.
    ///
    /// - Parameters:
    ///   - redirect: redirect to handle.
    ///   - returnUrl: Return URL specified when creating invoice or customer token.
    ///   - completion: Completion to invoke when redirect handling ends.
    public convenience init(
        redirect: PO3DSRedirect,
        returnUrl: URL,
        completion: @escaping (Result<String, POFailure>) -> Void
    ) {
        let completionBox: Completion = { result in
            completion(result.map(Self.token(with:)))
        }
        let callback = POWebAuthenticationSessionCallback.customScheme(returnUrl.scheme ?? "")
        self.init(url: redirect.url, callback: callback, timeout: redirect.timeout, completion: completionBox)
    }

    // MARK: - Private Methods

    private static func token(with url: URL) -> String {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        return components?.queryItems?.first { $0.name == "token" }?.value ?? ""
    }
}

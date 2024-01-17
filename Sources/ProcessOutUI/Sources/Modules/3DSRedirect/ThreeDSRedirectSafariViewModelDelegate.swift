//
//  ThreeDSRedirectSafariViewModelDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.11.2022.
//

import Foundation
import ProcessOut

final class ThreeDSRedirectSafariViewModelDelegate: DefaultSafariViewModelDelegate {

    typealias Completion = (Result<String, POFailure>) -> Void

    init(completion: @escaping Completion) {
        self.completion = completion
    }

    // MARK: - DefaultSafariViewModelDelegate

    func complete(with url: URL) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw POFailure(message: nil, code: .internal(.mobile), underlyingError: nil)
        }
        let token = components.queryItems?.first { item in
            item.name == Constants.tokenQueryItemName
        }
        completion(.success(token?.value ?? ""))
    }

    func complete(with failure: POFailure) {
        completion(.failure(failure))
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let tokenQueryItemName = "token"
    }

    // MARK: - Private Properties

    private let completion: Completion
}

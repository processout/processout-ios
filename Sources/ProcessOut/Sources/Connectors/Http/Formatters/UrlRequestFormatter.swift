//
//  UrlRequestFormatter.swift
//  
//
//  Created by Andrii Vysotskyi on 30.01.2023.
//

import Foundation

final class UrlRequestFormatter {

    /// Converts given request to string.
    func string(from request: URLRequest) -> String {
        var components: [String] = [
            [request.httpMethod, request.url.flatMap(string)].compactMap { $0 }.joined(separator: " ")
        ]
        if let headers = request.allHTTPHeaderFields {
            let description = headers
                .map { "\($0.key): \($0.value)" }
                .joined(separator: "\n")
            components.append(description)
        }
        if let body = request.httpBody {
            let bodyDescription = String(decoding: body, as: UTF8.self)
            components.append(bodyDescription)
        }
        return components.filter { !$0.isEmpty }.joined(separator: "\n\n")
    }

    // MARK: - Private Methods

    private func string(from url: URL) -> String? {
        let components = [url.path, url.query].compactMap { $0 }.filter { !$0.isEmpty }
        guard !components.isEmpty else {
            return nil
        }
        return components.joined(separator: "?")
    }
}

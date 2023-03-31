//
//  UrlRequestFormatter.swift
//  
//
//  Created by Andrii Vysotskyi on 30.01.2023.
//

import Foundation

final class UrlRequestFormatter {

    init(prettyPrintedBody: Bool = true) {
        self.prettyPrintedBody = prettyPrintedBody
    }

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
            let bodyDescription: String
            if prettyPrintedBody {
                do {
                    let json = try JSONSerialization.jsonObject(with: body, options: .fragmentsAllowed)
                    let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    bodyDescription = String(decoding: jsonData, as: UTF8.self)
                } catch {
                    bodyDescription = String(decoding: body, as: UTF8.self)
                }
            } else {
                bodyDescription = String(decoding: body, as: UTF8.self)
            }
            components.append(bodyDescription)
        }
        return components.filter { !$0.isEmpty }.joined(separator: "\n\n")
    }

    // MARK: - Private Properties

    private let prettyPrintedBody: Bool

    // MARK: - Private Methods

    private func string(from url: URL) -> String? {
        let components = [url.path, url.query].compactMap { $0 }.filter { !$0.isEmpty }
        guard !components.isEmpty else {
            return nil
        }
        return components.joined(separator: "?")
    }
}

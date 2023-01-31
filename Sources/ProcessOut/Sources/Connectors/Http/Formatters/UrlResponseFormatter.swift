//
//  UrlResponseFormatter.swift
//  
//
//  Created by Andrii Vysotskyi on 30.01.2023.
//

import Foundation

final class UrlResponseFormatter {

    init(includesHeaders: Bool) {
        self.includesHeaders = includesHeaders
    }

    /// Converts given response to string.
    func string(from response: URLResponse, data: Data? = nil) -> String {
        var components: [String] = []
        if let httpResponse = response as? HTTPURLResponse {
            components.append("HTTP \(httpResponse.statusCode)")
            if includesHeaders {
                let headersDescription = httpResponse.allHeaderFields
                    .map { "\($0.key): \($0.value)" }
                    .joined(separator: "\n")
                components.append(headersDescription)
            }
        }
        if let data = data {
            let dataDescription = String(decoding: data, as: UTF8.self)
            components.append(dataDescription)
        }
        return components.filter { !$0.isEmpty }.joined(separator: "\n\n")
    }

    // MARK: - Private Properties

    private let includesHeaders: Bool
}

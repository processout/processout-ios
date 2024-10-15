//
//  UrlResponseFormatter.swift
//  
//
//  Created by Andrii Vysotskyi on 30.01.2023.
//

import Foundation

final class UrlResponseFormatter: Sendable {

    init(includesHeaders: Bool, prettyPrintedBody: Bool = true) {
        self.includesHeaders = includesHeaders
        self.prettyPrintedBody = prettyPrintedBody
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
            let dataDescription: String
            if prettyPrintedBody {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    dataDescription = String(decoding: jsonData, as: UTF8.self)
                } catch {
                    dataDescription = String(decoding: data, as: UTF8.self)
                }
            } else {
                dataDescription = String(decoding: data, as: UTF8.self)
            }
            components.append(dataDescription)
        }
        return components.filter { !$0.isEmpty }.joined(separator: "\n\n")
    }

    // MARK: - Private Properties

    private let includesHeaders: Bool
    private let prettyPrintedBody: Bool
}

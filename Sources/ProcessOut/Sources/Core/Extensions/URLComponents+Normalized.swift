//
//  URLComponents+Normalized.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.02.2025.
//

import Foundation

extension URLComponents {

    var normalizedScheme: String? {
        scheme?.lowercased()
    }

    var normalizedHost: String? {
        guard var host else {
            return nil
        }
        while host.hasSuffix(".") {
            host.removeLast()
        }
        return host // todo(andrii-vysotskyi): use encodedHost to return punycode encoded host
    }

    var normalizedPath: String {
        var hadSuffix = false, path = self.path
        while path.hasSuffix("/") {
            path.removeLast()
            hadSuffix = true
        }
        if hadSuffix || path.isEmpty {
            path += "/"
        }
        return path
    }
}

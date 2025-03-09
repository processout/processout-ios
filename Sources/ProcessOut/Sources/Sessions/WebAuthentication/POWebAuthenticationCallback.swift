//
//  POWebAuthenticationCallback.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.10.2024.
//

import Foundation

/// An object used to evaluate navigation events in a web authentication session.
public struct POWebAuthenticationCallback: Sendable {

    enum Value: Sendable {

        /// Matches against URLs with the given custom scheme.
        case scheme(String)

        /// Matches against HTTPS URLs with the given host and path.
        case https(host: String, path: String)
    }

    /// Actual callback value.
    let value: Value

    /// Determines whether the given URL matches the callback criteria.
    func matches(url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }
        switch value {
        case .scheme(let scheme):
            var testComponents = URLComponents()
            testComponents.scheme = scheme
            return components.normalizedScheme == testComponents.normalizedScheme
        case let .https(host, path):
            guard let testComponents = URLComponents(string: "https://\(host)/\(path)") else {
                return false
            }
            return components.normalizedScheme == testComponents.normalizedScheme
                && components.normalizedHost == testComponents.normalizedHost
                && components.normalizedPath == testComponents.normalizedPath
        }
    }
}

extension POWebAuthenticationCallback {

    /// Creates a callback object that matches against URLs with the given custom scheme.
    /// - Parameters:
    ///   - customScheme: The custom scheme that the app expects in the callback URL.
    public static func customScheme(_ customScheme: String) -> Self {
        .init(value: .scheme(customScheme))
    }

    /// Creates a callback object that matches against HTTPS URLs with the given host and path.
    ///
    /// - Parameters:
    ///   - host: The host that the app expects in the callback URL. The host must be associated with the
    ///   app using associated web credentials domains.
    ///   - path: The path that the app expects in the callback URL.
    @available(iOS 17.4, *)
    public static func https(host: String, path: String) -> Self {
        .init(value: .https(host: host, path: path))
    }
}

// MARK: - Coding

extension POWebAuthenticationCallback: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(POWebAuthenticationCallback.Value.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

extension POWebAuthenticationCallback.Value: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try container.decodeIfPresent(String.self, forKey: .scheme) {
            self = .scheme(value)
        } else {
            let value = try container.decode(Https.self, forKey: .https)
            self = .https(host: value.host, path: value.path)
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .scheme(let scheme):
            try container.encode(scheme, forKey: .scheme)
        case let .https(host, path):
            try container.encode(Https(host: host, path: path), forKey: .https)
        }
    }

    // MARK: - Private Nested Types

    private struct Https: Codable {
        let host, path: String
    }

    private enum CodingKeys: String, CodingKey {
        case scheme, https
    }

    private enum HttpsCodingKeys: String, CodingKey {
        case host, path
    }
}

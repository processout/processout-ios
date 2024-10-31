//
//  POWebAuthenticationCallback.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.10.2024.
//

/// An object used to evaluate navigation events in an authentication session. When the session navigates
/// to a matching URL, it will pass the URL to the session completion handler.
public struct POWebAuthenticationCallback: Sendable {

    enum Value: Sendable {

        /// Matches against URLs with the given custom scheme.
        case scheme(String)

        /// Matches against HTTPS URLs with the given host and path.
        case https(host: String, path: String)
    }

    /// Actual callback value.
    let value: Value
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

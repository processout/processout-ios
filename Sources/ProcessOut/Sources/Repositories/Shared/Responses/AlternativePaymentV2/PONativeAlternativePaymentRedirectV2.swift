//
//  PONativeAlternativePaymentRedirectV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.06.2025.
//

import Foundation

/// Redirect details.
public struct PONativeAlternativePaymentRedirectV2: Decodable, Sendable {

    public struct RedirectType: Hashable, RawRepresentable, Sendable {

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        /// Raw value.
        public let rawValue: String
    }

    /// Destination URL.
    public let url: URL

    /// Display hint describing redirect purpose.
    public let hint: String

    /// Redirect type.
    public let type: RedirectType

    /// Boolean value indicating whether backend expects redirect confirmation after customer
    /// is redirected to url.
    public let confirmationRequired: Bool
}

extension PONativeAlternativePaymentRedirectV2.RedirectType: Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
}

extension PONativeAlternativePaymentRedirectV2.RedirectType {

    /// Web redirect.
    public static let web = Self(rawValue: "web")

    /// Deep link redirect.
    public static let deepLink = Self(rawValue: "deep_link")
}

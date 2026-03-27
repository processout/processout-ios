//
//  PONativeAlternativePaymentUrlResolutionRequestV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.03.2026.
//

import Foundation

@_spi(PO)
public struct PONativeAlternativePaymentUrlResolutionRequestV2: Sendable, Encodable {

    public struct Redirect: Sendable, Encodable {

        public struct Result: Sendable, Encodable { // swiftlint:disable:this nesting

            /// Result URL.
            public let url: URL
        }

        /// Redirect result.
        public let result: Result
    }

    /// Redirect information.
    public let redirect: Redirect

    public init(redirect: Redirect) {
        self.redirect = redirect
    }
}

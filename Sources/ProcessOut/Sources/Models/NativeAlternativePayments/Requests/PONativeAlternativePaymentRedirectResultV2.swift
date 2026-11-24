//
//  PONativeAlternativePaymentRedirectResultV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.12.2025.
//

import Foundation

public struct PONativeAlternativePaymentRedirectResultV2: Sendable, Encodable {

    @_spi(PO)
    public struct Result: Sendable, Encodable {

        /// Result URL.
        public let url: URL

        public init(url: URL) {
            self.url = url
        }
    }

    /// Indicates whether customer was redirected successfully.
    public let success: Bool

    /// Redirect result.
    @_spi(PO)
    public let result: Result?

    @_spi(PO)
    public init(success: Bool, result: Result?) {
        self.success = success
        self.result = result
    }

    public init(success: Bool) {
        self.success = success
        self.result = nil
    }
}

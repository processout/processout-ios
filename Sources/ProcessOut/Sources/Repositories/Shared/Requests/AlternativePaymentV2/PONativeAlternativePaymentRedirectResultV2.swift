//
//  PONativeAlternativePaymentRedirectResultV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.12.2025.
//

public struct PONativeAlternativePaymentRedirectResultV2: Sendable, Encodable {

    public init(success: Bool) {
        self.success = success
    }

    /// indicates whether customer was redirected successfully.
    public let success: Bool
}

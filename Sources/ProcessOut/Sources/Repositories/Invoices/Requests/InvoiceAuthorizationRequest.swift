//
//  InvoiceAuthorizationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.11.2026.
//

import Foundation

struct InvoiceAuthorizationRequest: Encodable, Sendable { // sourcery: AutoCodingKeys

    /// Invoice identifier to perform authorization for.
    let invoiceId: String // sourcery:coding: skip

    /// Payment source to use for authorization.
    let source: String

    /// Indicates whether payment source should be saved by creating a customer token during the authorization.
    let saveSource: Bool

    /// Boolean value indicating if authorization is incremental.
    let incremental: Bool

    /// Indicates that request is coming directly from the frontend, so it is possible to instantly step-up to 3DS.
    let enableThreeDS2 = true // sourcery:coding: key="enable_three_d_s_2"

    /// Card scheme or co-scheme that should get priority if it is available.
    let preferredScheme: POCardScheme?

    /// Third party SDK version that is used to handle 3DS2.
    let thirdPartySdkVersion: String?

    /// Indicates whether transaction blocking due to MasterCard Merchant Advice Code should be overridden.
    let overrideMacBlocking: Bool

    /// Scheme ID to use for subsequent CIT/MITs if applicable.
    let initialSchemeTransactionId: String?

    /// Date when payment should be captured automatically.
    let autoCaptureAt: Date?

    /// Amount of money to capture when partial captures are available.
    @POImmutableStringCodableOptionalDecimal
    var captureAmount: Decimal?

    /// Indicates whether authorization may fall back to sale.
    let allowFallbackToSale: Bool

    /// A secret key associated with the client making the request.
    let clientSecret: String? // sourcery:coding: skip

    /// Operation metadata.
    let metadata: [String: String]?

    /// Customer's locale identifier override.
    let localeIdentifier: String? // sourcery:coding: skip
}

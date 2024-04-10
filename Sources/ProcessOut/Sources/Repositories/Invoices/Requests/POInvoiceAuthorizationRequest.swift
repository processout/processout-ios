//
//  POInvoiceAuthorizationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.10.2022.
//

import Foundation

public struct POInvoiceAuthorizationRequest: Encodable { // sourcery: AutoCodingKeys

    /// Invoice identifier to to perform authorization for.
    public let invoiceId: String // sourcery:coding: skip

    /// Payment source to use for authorization.
    public let source: String

    /// Boolean value indicating if authorization is incremental. Default value is `false`.
    public let incremental: Bool

    /// Boolean value indicating whether 3DS2 is enabled. Default value is `true`.
    public let enableThreeDS2: Bool // sourcery:coding: key="enable_three_d_s_2"

    /// Card scheme or co-scheme that should get priority if it is available.
    public let preferredScheme: String?

    /// Can be used for a 3DS2 request to indicate which third party SDK is used for the call.
    public let thirdPartySdkVersion: String?

    /// Can be used to to provide specific ids to indicate which of items provided in invoice details list
    /// are subject to capture.
    public let invoiceDetailIds: [String]?

    /// Allows to specify if transaction blocking due to MasterCard Merchant Advice Code should be applied or not.
    /// Default is `false`.
    public let overrideMacBlocking: Bool

    /// Allows to specify which scheme ID to use for subsequent CIT/MITs if applicable.
    public let initialSchemeTransactionId: String?

    /// You can set this property to arrange for the payment to be captured automatically after a time delay.
    public let autoCaptureAt: Date?

    /// Amount of money to capture when partial captures are available. Note that this only applies if you are
    /// also using the `autoCaptureAt` option.
    @POImmutableStringCodableOptionalDecimal
    public var captureAmount: Decimal?

    /// Set to true if you want to authorize payment without capturing. Note that you must capture the payment on
    /// the server if you use this option. Default value is `true`.
    public let authorizeOnly: Bool

    /// Setting this property to `true` allows to prefer doing an authorization, but to fall back to
    /// a sale payment if separation between authorization and capture is not available. Default
    /// value is `false`.
    public let allowFallbackToSale: Bool

    /// Operation metadata.
    public let metadata: [String: String]?

    public init(
        invoiceId: String,
        source: String,
        incremental: Bool = false,
        enableThreeDS2: Bool = true,
        preferredScheme: String? = nil,
        thirdPartySdkVersion: String? = nil,
        invoiceDetailIds: [String]? = nil,
        overrideMacBlocking: Bool = false,
        initialSchemeTransactionId: String? = nil,
        autoCaptureAt: Date? = nil,
        captureAmount: Decimal? = nil,
        authorizeOnly: Bool = true,
        allowFallbackToSale: Bool = false,
        metadata: [String: String]? = nil
    ) {
        self.invoiceId = invoiceId
        self.source = source
        self.incremental = incremental
        self.enableThreeDS2 = enableThreeDS2
        self.preferredScheme = preferredScheme
        self.thirdPartySdkVersion = thirdPartySdkVersion
        self.invoiceDetailIds = invoiceDetailIds
        self.overrideMacBlocking = overrideMacBlocking
        self.initialSchemeTransactionId = initialSchemeTransactionId
        self.autoCaptureAt = autoCaptureAt
        self._captureAmount = .init(value: captureAmount)
        self.authorizeOnly = authorizeOnly
        self.allowFallbackToSale = allowFallbackToSale
        self.metadata = metadata
    }
}

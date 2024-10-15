//
//  POGatewayConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

import Foundation

public struct POGatewayConfiguration: Decodable, Sendable {

    @available(*, deprecated, message: "Use POInvoicesService/nativeAlternativePaymentMethodTransactionDetails(request:) instead.") // swiftlint:disable:this line_length
    public struct NativeAlternativePaymentMethodConfig: Decodable, Sendable {

        /// Configuration parameters.
        public let parameters: [PONativeAlternativePaymentMethodParameter]
    }

    public struct Gateway: Decodable, Sendable {

        /// Name is the name of the payment gateway.
        public let name: String

        /// Name of the payment gateway that can be displayed.
        public let displayName: String

        /// Gateway's logo URL.
        public let logoUrl: URL

        /// URL of the payment gateway.
        public let url: URL

        /// Gateway tags. Mainly used to filter gateways depending on their attributes (e-wallets and such).
        public let tags: [String]

        /// Boolean flag that identifies if the gateway can pull old transactions into ProcessOut.
        public let canPullTransactions: Bool

        /// Boolean flag that indicates whether gateway supports refunds.
        public let canRefund: Bool

        /// Native alternative payment method configuration.
        @available(*, deprecated, message: "Use POInvoicesService/nativeAlternativePaymentMethodTransactionDetails(request:) instead.") // swiftlint:disable:this line_length
        public let nativeApmConfig: NativeAlternativePaymentMethodConfig?
    }

    /// String value that uniquely identifies the configuration.
    public let id: String

    /// Gateway that the configuration configures.
    public let gateway: Gateway?

    /// Id of the gateway to which the gateway configuration belongs.
    public let gatewayId: Int

    /// Gateway name.
    public let gatewayName: String?

    /// Name of the gateway configuration.
    public let name: String?

    /// Default currency of the gateway configuration.
    public let defaultCurrency: String

    /// Country code of merchant's account.
    public let merchantAccountCountryCode: String?

    /// Enabled sub accounts.
    public let subAccountsEnabled: [String]?

    /// Boolean flag indicates whether configuration is currently enabled or not.
    public let enabled: Bool

    /// Date at which the gateway configuration was created.
    public let createdAt: Date

    /// Date at which the gateway configuration was enabled.
    public let enabledAt: Date?
}

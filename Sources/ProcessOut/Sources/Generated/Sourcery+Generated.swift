// Generated using Sourcery 2.4.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import UIKit

// MARK: - AutoCodingKeys

extension AssignCustomerTokenRequest {

    enum CodingKeys: String, CodingKey {
        case source
        case preferredScheme
        case verify
        case invoiceId
        case enableThreeDS2 = "enable_three_d_s_2"
        case thirdPartySdkVersion
        case metadata
    }
}

extension InvoiceAuthorizationRequest {

    enum CodingKeys: String, CodingKey {
        case source
        case saveSource
        case incremental
        case enableThreeDS2 = "enable_three_d_s_2"
        case preferredScheme
        case thirdPartySdkVersion
        case overrideMacBlocking
        case initialSchemeTransactionId
        case autoCaptureAt
        case captureAmount
        case allowFallbackToSale
        case metadata
    }
}

extension NativeAlternativePaymentCaptureRequest {

    enum CodingKeys: String, CodingKey {
        case source
    }
}

extension POAssignCustomerTokenRequest {

    enum CodingKeys: String, CodingKey {
        case customerId
        case tokenId
        case source
        case preferredScheme
        case verify
        case invoiceId
        case enableThreeDS2 = "enable_three_d_s_2"
        case thirdPartySdkVersion
        case metadata
        case prefersEphemeralWebAuthenticationSession
        case localeIdentifier
    }
}

extension PODynamicCheckoutPaymentMethod.AlternativePayment {

    enum CodingKeys: String, CodingKey {
        case display
        case flow
        case configuration = "apm"
    }
}

extension PODynamicCheckoutPaymentMethod.ApplePay {

    enum CodingKeys: String, CodingKey {
        case flow
        case configuration = "applepay"
    }
}

extension PODynamicCheckoutPaymentMethod.Card {

    enum CodingKeys: String, CodingKey {
        case display
        case configuration = "card"
    }
}

extension PODynamicCheckoutPaymentMethod.NativeAlternativePayment {

    enum CodingKeys: String, CodingKey {
        case display
        case configuration = "apm"
    }
}

extension POInvoiceAuthorizationRequest {

    enum CodingKeys: String, CodingKey {
        case invoiceId
        case source
        case saveSource
        case incremental
        case enableThreeDS2 = "enable_three_d_s_2"
        case preferredScheme
        case thirdPartySdkVersion
        case overrideMacBlocking
        case initialSchemeTransactionId
        case autoCaptureAt
        case captureAmount
        case allowFallbackToSale
        case clientSecret
        case metadata
        case webAuthenticationCallback
        case prefersEphemeralWebAuthenticationSession
    }
}

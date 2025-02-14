// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import UIKit

// MARK: - AutoCodingKeys

extension DeviceMetadata {

    enum CodingKeys: String, CodingKey {
        case appLanguage
        case appScreenWidth
        case appScreenHeight
        case appTimeZoneOffset
        case channel
    }
}

extension NativeAlternativePaymentCaptureRequest {

    enum CodingKeys: String, CodingKey {
        case source
    }
}

extension POAssignCustomerTokenRequest {

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

extension POCardUpdateRequest {

    enum CodingKeys: String, CodingKey {
        case cvc
        case preferredScheme
    }
}

extension POCreateCustomerTokenRequest {

    enum CodingKeys: String, CodingKey {
        case verify
        case returnUrl
        case invoiceReturnUrl
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
        case source
        case saveSource
        case incremental
        case enableThreeDS2 = "enable_three_d_s_2"
        case preferredScheme
        case thirdPartySdkVersion
        case invoiceDetailIds
        case overrideMacBlocking
        case initialSchemeTransactionId
        case autoCaptureAt
        case captureAmount
        case authorizeOnly
        case allowFallbackToSale
        case metadata
    }
}

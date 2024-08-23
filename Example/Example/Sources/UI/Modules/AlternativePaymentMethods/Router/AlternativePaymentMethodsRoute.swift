//
//  AlternativePaymentMethodsRoute.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import Foundation
import ProcessOut

enum AlternativePaymentMethodsRoute: RouteType {

    struct NativeAlternativePayment {

        /// Gateway configuration id.
        let gatewayConfigurationId: String

        /// Invoice id.
        let invoiceId: String

        /// Completion to invoke with payment result.
        let completion: (Result<Void, POFailure>) -> Void
    }

    /// Alternative payment executed natively.
    case nativeAlternativePayment(NativeAlternativePayment)

    /// Alternative payment.
    case alternativePayment(request: POAlternativePaymentMethodRequest)

    /// Asks user for authorisation amount and currency.
    case authorizationtAmount(completion: (Decimal, String) -> Void)

    /// Alert that shows given message.
    case alert(message: String)
}

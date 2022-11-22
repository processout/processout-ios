//
//  AlternativePaymentMethodsRoute.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import Foundation
import ProcessOut

enum AlternativePaymentMethodsRoute: RouteType {
    case nativeAlternativePayment(gatewayConfigurationId: String, invoiceId: String)
    case authorizationtAmount(completion: (Decimal, String) -> Void)
}

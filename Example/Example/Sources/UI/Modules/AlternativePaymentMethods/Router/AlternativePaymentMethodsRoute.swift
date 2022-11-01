//
//  AlternativePaymentMethodsRoute.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

enum AlternativePaymentMethodsRoute: RouteType {
    case nativeAlternativePayment(gatewayConfigurationId: String, invoiceId: String)
}

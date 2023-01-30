//
//  AlternativePaymentDataRoute.swift
//  Example
//
//  Created by Andrii Vysotskyi on 25.01.2023.
//

enum AlternativePaymentDataRoute: RouteType {
    case close
    case additionalData(completion: (_ key: String, _ value: String) -> Void)
}

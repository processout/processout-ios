//
//  NativeAlternativePaymentMethodRoute.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.10.2022.
//

enum NativeAlternativePaymentMethodRoute: RouteType {
    case close(completion: (() -> Void)?)
}

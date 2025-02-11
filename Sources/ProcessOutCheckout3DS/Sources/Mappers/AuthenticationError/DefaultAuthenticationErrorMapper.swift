//
//  DefaultAuthenticationErrorMapper.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 06.03.2023.
//

import ProcessOut
import Checkout3DS

struct DefaultAuthenticationErrorMapper: AuthenticationErrorMapper {

    func convert(error: AuthenticationError) -> POFailure {
        let code: POFailureCode
        switch error {
        case .challengeCancelled:
            code = .Mobile.cancelled
        case .challengeTimeout, .connectionTimeout:
            code = .Mobile.timeout
        case .noInternetConnectivity,
             .connectionFailed,
             .connectionLost,
             .internationalRoamingOff,
             .unknownNetworkError:
            code = .Mobile.networkUnreachable
        default:
            code = .Mobile.generic
        }
        return POFailure(code: code, underlyingError: error)
    }
}

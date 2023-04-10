//
//  DefaultAuthenticationErrorMapper.swift
//  ProcessOutCheckout
//
//  Created by Andrii Vysotskyi on 06.03.2023.
//

import ProcessOut
import Checkout3DS

final class DefaultAuthenticationErrorMapper: AuthenticationErrorMapper {

    func convert(error: AuthenticationError) -> POFailure {
        let code: POFailure.Code
        switch error {
        case .challengeCancelled:
            code = .cancelled
        case .challengeTimeout, .connectionTimeout:
            code = .timeout(.mobile)
        case .noInternetConnectivity,
             .connectionFailed,
             .connectionLost,
             .internationalRoamingOff,
             .unknownNetworkError:
            code = .networkUnreachable
        default:
            code = .generic(.mobile)
        }
        return POFailure(code: code, underlyingError: error)
    }
}

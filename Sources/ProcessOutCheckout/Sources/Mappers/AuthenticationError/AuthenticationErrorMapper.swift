//
//  AuthenticationErrorMapper.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 06.03.2023.
//

import ProcessOut
import Checkout3DS

final class AuthenticationErrorMapper: AuthenticationErrorMapperType {

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
        case .invalidSessionID,
             .unauthorizedSessionsRequest,
             .authenticationVerificationUnsuccessful,
             .duplicateAuthenticationRequest,
             .concurrentAuthenticationRequest,
             .sdkNotInitialised,
             .certificateTransparencyChecksFailed:
            code = .internal(.mobile)
        case .sdkPListModified, .certificateTransparencyOverriddenByApp, .duplicateSDKInitialised:
            code = .generic(.mobile)
        default: // threeDS2ProtocolErrorXXXX and internalErrorXXXX
            code = .generic(.mobile)
        }
        return POFailure(code: code, underlyingError: error)
    }
}

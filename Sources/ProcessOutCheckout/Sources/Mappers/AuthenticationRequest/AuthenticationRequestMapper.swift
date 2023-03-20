//
//  AuthenticationRequestMapper.swift
//  ProcessOutCheckout
//
//  Created by Andrii Vysotskyi on 06.03.2023.
//

@_spi(PO) import ProcessOut
import Checkout3DS

final class AuthenticationRequestMapper: AuthenticationRequestMapperType {

    init(decoder: JSONDecoder) {
        self.decoder = decoder
    }

    // MARK: - MapperType

    func convert(request: AuthenticationRequestParameters) -> Result<PO3DS2AuthenticationRequest, POFailure> {
        let authenticationRequest = PO3DS2AuthenticationRequest(
            deviceData: request.deviceData,
            sdkAppId: request.sdkAppID,
            sdkEphemeralPublicKey: request.sdkEphemeralPublicKey,
            sdkReferenceNumber: request.sdkReferenceNumber,
            sdkTransactionId: request.sdkTransactionID
        )
        return .success(authenticationRequest)
    }

    // MARK: - Private Properties

    private let decoder: JSONDecoder
}

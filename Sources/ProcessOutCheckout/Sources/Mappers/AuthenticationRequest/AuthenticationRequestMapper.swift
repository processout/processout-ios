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

    func convert(request: AuthenticationRequestParameters) -> Result<PO3DSAuthenticationRequest, POFailure> {
        do {
            let fingerprint = PO3DSAuthenticationRequest(
                deviceInformation: request.deviceData,
                applicationId: request.sdkAppID,
                sdkEphemeralPublicKey: try decoder.decode(
                    PO3DSAuthenticationRequest.EphemeralPublicKey.self, from: Data(request.sdkEphemeralPublicKey.utf8)
                ),
                sdkReferenceNumber: request.sdkReferenceNumber,
                sdkTransactionId: request.sdkTransactionID
            )
            return .success(fingerprint)
        } catch {
            let failure = POFailure(code: .internal(.mobile), underlyingError: error)
            return .failure(failure)
        }
    }

    // MARK: - Private Properties

    private let decoder: JSONDecoder
}

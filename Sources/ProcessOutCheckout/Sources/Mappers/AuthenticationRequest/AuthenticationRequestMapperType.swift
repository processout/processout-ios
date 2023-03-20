//
//  AuthenticationRequestMapperType.swift
//  ProcessOutCheckout
//
//  Created by Andrii Vysotskyi on 06.03.2023.
//

@_spi(PO) import ProcessOut
import Checkout3DS

protocol AuthenticationRequestMapperType {

    /// Converts given request to fingerprint.
    func convert(request: AuthenticationRequestParameters) -> Result<PO3DS2AuthenticationRequest, POFailure>
}

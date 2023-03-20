//
//  PO3DSServiceType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2022.
//

import Foundation

/// Thi interface provides methods to process 3-D Secure transactions.
@_spi(PO)
public protocol PO3DSServiceType: AnyObject {

    /// Fingerprints the device and creates request that the 3DS Server requires to create the AReq.
    func authenticationRequest(
        configuration: PO3DS2Configuration,
        completion: @escaping (Result<PO3DS2AuthenticationRequest, POFailure>) -> Void
    )

    /// Performs given 3DS2 challenge.
    func perform(challenge: PO3DS2Challenge, completion: @escaping (Result<Bool, POFailure>) -> Void)

    /// Asks delegate to perform redirect.
    func redirect(context: PO3DSRedirectContext, completion: @escaping (Result<String, POFailure>) -> Void)
}

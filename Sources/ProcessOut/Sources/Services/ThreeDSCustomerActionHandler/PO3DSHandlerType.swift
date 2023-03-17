//
//  PO3DSHandlerType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2022.
//

import Foundation

@_spi(PO)
public protocol PO3DSHandlerType: AnyObject {

    /// Asks delegate to fingerprint the device and provide parameters to use for AReq.
    func authenticationRequest(
        data: PODirectoryServerData,
        completion: @escaping (Result<PO3DSAuthenticationRequest, POFailure>) -> Void
    )

    /// Asks delegate to perform given challenge.
    func perform(challenge: PO3DSChallenge, completion: @escaping (Result<Bool, POFailure>) -> Void)

    /// Asks delegate to perform redirect.
    func redirect(context: PORedirectCustomerActionContext, completion: @escaping (Result<String, POFailure>) -> Void)
}

//
//  POCustomerActionHandlerDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2022.
//

import Foundation

@_spi(PO)
public protocol POCustomerActionHandlerDelegate: AnyObject {

    /// Asks delegate to fingerprint the device.
    func fingerprint(
        data: PODirectoryServerData, completion: @escaping (Result<PODeviceFingerprint, POFailure>) -> Void
    )

    /// Asks delegate to perform given challenge.
    func challenge(challenge: POAuthentificationChallengeData, completion: @escaping (Result<Bool, POFailure>) -> Void)

    /// Asks delegate to perform redirect.
    func redirect(context: PORedirectCustomerActionContext, completion: @escaping (Result<String, POFailure>) -> Void)
}

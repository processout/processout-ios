//
//  POCustomerActionHandlerDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2022.
//

import Foundation

public protocol POCustomerActionHandlerDelegate: AnyObject {

    /// Asks delegate to fingerprint the device.
    func fingerprint(data: PODirectoryServerData, completion: @escaping (Result<PODeviceFingerprint, Error>) -> Void)

    /// Asks delegate to perform given challenge.
    func challenge(challenge: POAuthentificationChallengeData, completion: @escaping (Result<Bool, Error>) -> Void)

    /// Asks delegate to perform redirection to given url.
    func redirect(url: URL, completion: @escaping (Result<String, Error>) -> Void)

    /// Asks delegate for device fingeprint that could be done by redirecting to given url using
    /// browser in a "headless" mode.
    func fingerprint(url: URL, completion: @escaping (Result<String, Error>) -> Void)
}

//
//  ThreeDSTestHandler.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.01.2023.
//

import UIKit

@available(*, deprecated)
public class ThreeDSTestHandler: ThreeDSHandler {

    var completion: (String?, ProcessOutException?) -> Void

    public init(controller: UIViewController, completion: @escaping (String?, ProcessOutException?) -> Void) {
        self.completion = completion
    }

    public func doFingerprint(directoryServerData: DirectoryServerData, completion: (ThreeDSFingerprintResponse) -> Void) {
        completion(ThreeDSFingerprintResponse(sdkEncData: "", sdkAppID: "", sdkEphemPubKey: nil, sdkReferenceNumber: "", sdkTransID: ""))

    }

    public func doChallenge(authentificationData: AuthentificationChallengeData, completion: @escaping (Bool) -> Void) {
        completion(false)
    }

    public func doPresentWebView(webView: ProcessOutWebView) {
        // Ignored
    }

    public func onSuccess(invoiceId: String) {
        completion(invoiceId, nil)
    }

    public func onError(error: ProcessOutException) {
        completion(nil, error)
    }
}

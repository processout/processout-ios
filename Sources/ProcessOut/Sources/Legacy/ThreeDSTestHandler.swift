//
//  ThreeDSTestHandler.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.01.2023.
//

import UIKit

@available(*, deprecated, message: "Declaration will be removed in version 4.0.")
public class ThreeDSTestHandler: ThreeDSHandler {

    var controller: UIViewController
    var completion: (String?, ProcessOutException?) -> Void
    var webView: ProcessOutWebView?

    public init(controller: UIViewController, completion: @escaping (String?, ProcessOutException?) -> Void) {
        self.controller = controller
        self.completion = completion
    }

    public func doFingerprint(directoryServerData: DirectoryServerData, completion: (ThreeDSFingerprintResponse) -> Void) {
        completion(ThreeDSFingerprintResponse(sdkEncData: "", sdkAppID: "", sdkEphemPubKey: ThreeDSFingerprintResponse.SDKEphemPubKey(), sdkReferenceNumber: "", sdkTransID: ""))

    }

    public func doChallenge(authentificationData: AuthentificationChallengeData, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Do you want to accept the 3DS2 challenge", message: "", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { (action) in
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: "Reject", style: .default, handler: { (action) in
            completion(false)
        }))

        self.controller.present(alert, animated: true)
    }

    public func doPresentWebView(webView: ProcessOutWebView) {
        self.webView = webView
        controller.view.addSubview(webView)
    }

    public func onSuccess(invoiceId: String) {
        if self.webView != nil {
            webView!.removeFromSuperview()
        }
        self.completion(invoiceId, nil)
    }

    public func onError(error: ProcessOutException) {
        if self.webView != nil {
            webView!.removeFromSuperview()
        }
        self.completion(nil, error)
    }
}

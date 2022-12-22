//
//  ThreeDSHandler.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 17/06/2019.
//

import UIKit

/// Custom protocol which lets you implement a 3DS2 integration
public protocol ThreeDSHandler {
    /// method called when a device fingerprint is required
    ///
    /// - Parameters:
    ///   - directoryServerData: Contains information required by the third-party handling the device fingerprinting
    ///   - completion: Callback containing the fingerprint information
    func doFingerprint(directoryServerData: DirectoryServerData, completion: @escaping (ThreeDSFingerprintResponse) -> Void)
    
    /// Method called when a 3DS2 challenge is required
    ///
    /// - Parameters:
    ///   - authentificationData: Authentification data required to present the challenge
    ///   - completion: Callback specifying wheter or not the challenge was successful
    func doChallenge(authentificationData: AuthentificationChallengeData, completion: @escaping (Bool) -> Void)
    
    
    /// Method called when a web challenge is required
    ///
    /// - Parameter webView: The webView to present
    func doPresentWebView(webView: ProcessOutWebView)
    
    /// Called when the authorization was successful
    ///
    /// - Parameter invoiceId: Invoice id that was authorized
    func onSuccess(invoiceId: String)
    
    /// Called when the authorization process ends up in a failed state.
    ///
    /// - Parameter error: Error
    func onError(error: ProcessOutException)
}

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

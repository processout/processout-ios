//
//  CustomerActionHandler.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 19/09/2019.
//

import Foundation
import UIKit
import WebKit


class CustomerActionHandler {
    
    var handler: ThreeDSHandler
    var with: UIViewController
    var processOutWebView: ProcessOutWebView
    
    public init(handler: ThreeDSHandler, processOutWebView: ProcessOutWebView, with: UIViewController) {
        self.handler = handler
        self.with = with
        self.processOutWebView = processOutWebView
    }
    
    
    /// Handle a customer action request for an authorization
    ///
    /// - Parameters:
    ///   - customerAction: the customerAction returned by the auth request
    ///   - completion: completion callback
    public func handleCustomerAction(customerAction: CustomerAction, completion: @escaping (String) -> Void) {
        switch customerAction.type{
            // 3DS2 fingerprint request
        case .fingerPrintMobile:
            performFingerprint(customerAction: customerAction, handler: handler, completion: { (encodedData, error) in
                if encodedData != nil {
                    completion(encodedData!)
                } else {
                    self.handler.onError(error: error!)
                }
            })
            // 3DS2 challenge request
        case .challengeMobile:
            performChallenge(customerAction: customerAction, handler: handler) { (success, error) in
                if (success) {
                    completion(ProcessOut.threeDS2ChallengeSuccess)
                } else {
                    completion(ProcessOut.threeDS2ChallengeError)
                }
            }
            // 3DS1 web fallback
        case .url, .redirect:
            guard let url = URL(string: customerAction.value) else {
                // Invalid URL
                handler.onError(error: ProcessOutException.InternalError)
                return
            }

            // Loading the url
            let request = URLRequest(url: url)
            guard let _ = processOutWebView.load(request) else {
                handler.onError(error: ProcessOutException.InternalError)
                return
            }
            
            // Displaying the webview
            handler.doPresentWebView(webView: processOutWebView)
            
            break
            
        case .fingerprint:
            // Need to open a webview for fingerprinting fallback
            
            guard let url = URL(string: customerAction.value) else {
                // Invalid URL
                handler.onError(error: ProcessOutException.InternalError)
                return
            }
            // Prepare the fingerprint hiddenWebview
            var webView: WKWebView!
            let preferences = WKPreferences()
            preferences.javaScriptEnabled = true
            let configuration = WKWebViewConfiguration()
            // Check if the device supports custom URL scheme handling for WebViews
            if #available(iOS 11.0, *), let appURLScheme = ProcessOut.UrlScheme {
                // Setup the fingerprint timeout handler
                let timeOutHandler = DispatchWorkItem {
                    // Remove the webview
                    webView.removeFromSuperview()
                    webView = nil
                    // Fallback to default fingerprint values
                    let fallback = self.generateFallbackFingerprintToken(URL: customerAction.value)
                    guard fallback.error == nil else {
                        self.handler.onError(error: fallback.error!)
                        return
                    }
                    
                    completion(fallback.fallbackToken!)
                }
                configuration.preferences = preferences
                // Setup the custom URL scheme handler to detect redirects within the hidden webview
                configuration.setURLSchemeHandler(FingerPrintWebViewSchemeHandler(completion: {(invoiceId, token, error) in
                    // Cancel the timeout as we catched the redirect
                    timeOutHandler.cancel()
                    if error != nil {
                        self.handler.onError(error: error!)
                    } else {
                        // Fingerprint token successfully received, we continue the authorization flow
                        completion(token!)
                    }
                }), forURLScheme: appURLScheme)
                // Add the webview to the app view
                webView = WKWebView(frame: with.view.frame, configuration: configuration)
                webView.load(URLRequest(url: url))
                webView.isHidden = true
                with.view.addSubview(webView)
                
                // Start the timeout handler with a 10s timeout
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: timeOutHandler)
            } else {
                // Fallback on earlier versions
                let fallback = self.generateFallbackFingerprintToken(URL: customerAction.value)
                guard fallback.error == nil else {
                    handler.onError(error: fallback.error!)
                    return
                }
                
                completion(fallback.fallbackToken!)
            }
            
            break
        }
    }
    
    private func performFingerprint(customerAction: CustomerAction, handler: ThreeDSHandler, completion: @escaping (String?, ProcessOutException?) -> Void) {
        do {
            let decodedData = Data(base64Encoded: customerAction.value)!
            let directoryServerData = try JSONDecoder().decode(DirectoryServerData.self, from: decodedData)
            handler.doFingerprint(directoryServerData: directoryServerData) { (response) in
                do {
                    if let body = String(data: try JSONEncoder().encode(response), encoding: .utf8) {
                        let miscGatewayRequest = MiscGatewayRequest(fingerprintResponse: body)
                        if let gatewayToken = miscGatewayRequest.generateToken() {
                            completion(gatewayToken, nil)
                        } else {
                            completion(nil, ProcessOutException.InternalError)
                        }
                    } else {
                        completion(nil, ProcessOutException.InternalError)
                    }
                } catch {
                    completion(nil, ProcessOutException.InternalError)
                }
                
            }
        } catch {
            completion(nil, ProcessOutException.InternalError)
        }
    }
    
    private func performChallenge(customerAction: CustomerAction, handler: ThreeDSHandler, completion: @escaping (Bool, ProcessOutException?) -> Void) {
        do {
            if let decodedB64Data = Data(base64Encoded: customerAction.value) {
                let authentificationChallengeData = try JSONDecoder().decode(AuthentificationChallengeData.self, from: decodedB64Data)
                handler.doChallenge(authentificationData: authentificationChallengeData) { (success) in
                    completion(success, nil)
                }
            } else {
                completion(false, ProcessOutException.InternalError)
            }
        } catch {
            completion(false, ProcessOutException.InternalError)
        }
        
    }
    
    private func generateFallbackFingerprintToken(URL: String) -> (fallbackToken: String?, error: ProcessOutException?) {
        let miscGatewayRequest = MiscGatewayRequest(fingerprintResponse: "{\"threeDS2FingerprintTimeout\":true}")
        miscGatewayRequest.headers = ["Content-Type": "application/json"]
        miscGatewayRequest.url = URL
        if let gatewayToken = miscGatewayRequest.generateToken() {
            return (gatewayToken, nil)
        } else {
            return (nil, ProcessOutException.InternalError)
        }
    }
}

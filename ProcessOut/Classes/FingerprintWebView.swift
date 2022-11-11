//
//  FingerprintWebView.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 30/09/2019.
//

import UIKit

class FingerprintWebView: ProcessOutWebView {

    private var timeOutTimer: Timer?
    private let customerAction: CustomerAction
    
    public init(customerAction: CustomerAction, frame: CGRect, onResult: @escaping (String) -> Void, onAuthenticationError: @escaping () -> Void) {
        self.customerAction = customerAction
        super.init(frame: frame, onResult: onResult, onAuthenticationError: onAuthenticationError)
        self.isHidden = false
        
        // Start the timeout handler with a 10s timeout
        timeOutTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(timeOutTimerDidFire), userInfo: nil, repeats: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func generateFallbackFingerprintToken(URL: String) -> (fallbackToken: String?, error: ProcessOutException?) {
        let miscGatewayRequest = MiscGatewayRequest(fingerprintResponse: "{\"threeDS2FingerprintTimeout\":true}")
        miscGatewayRequest.headers = ["Content-Type": "application/json"]
        miscGatewayRequest.url = URL
        
        guard let gatewayToken = miscGatewayRequest.generateToken() else {
            return (nil, ProcessOutException.InternalError)
        }
        
        return (gatewayToken, nil)
    }
    
    override func onRedirect(url: URL) {
        guard let parameters = url.queryParameters, let token = parameters["token"] else {
            return
        }
        timeOutTimer?.invalidate()
        onResult(token)
    }
    
    @objc private func timeOutTimerDidFire() {
        // Remove the webview
        self.removeFromSuperview()

        // Fallback to default fingerprint values
        let fallback = self.generateFallbackFingerprintToken(URL: customerAction.value)
        guard fallback.error == nil else {
            onAuthenticationError()
            return
        }
        onResult(fallback.fallbackToken!)
    }
}

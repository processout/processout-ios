//
//  FingerPrintWebViewSchemeHandler.swift
//
//  Created by Jeremy Lejoux on 27/08/2019.
//

import Foundation
import WebKit

@available(iOS 11.0, *) // When not available we fallback to default fingerprinting values and continue the authorization flow
public class FingerPrintWebViewSchemeHandler: NSObject, WKURLSchemeHandler {
    
    private var completion: ((String?, String?, ProcessOutException?) -> Void)? = nil
    
    public init(completion: @escaping (String?, String?, ProcessOutException?) -> Void) {
        self.completion = completion
    }
    
    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        DispatchQueue.global().async {
            if let url = urlSchemeTask.request.url {
                var invoice = ""
                var token = ""
                if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems {
                    for queryParams in queryItems {
                        if queryParams.name == "invoice_id", let value = queryParams.value {
                            invoice = value
                        } else if queryParams.name == "token", let value = queryParams.value {
                            token = value
                        }
                    }
                }
                
                if invoice == "" || token == "" {
                    self.completion!(nil, nil, ProcessOutException.InternalError)
                    return
                }
                
                self.completion!(invoice, token, nil)
            }
        }
    }
    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
    }
}

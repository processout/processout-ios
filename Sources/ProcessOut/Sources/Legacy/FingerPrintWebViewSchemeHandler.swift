//
//  FingerPrintWebViewSchemeHandler.swift
//
//  Created by Jeremy Lejoux on 27/08/2019.
//

import Foundation
import WebKit

@available(*, deprecated)
public final class FingerPrintWebViewSchemeHandler: NSObject, WKURLSchemeHandler {
    
    private var completion: ((String?, String?, ProcessOutException?) -> Void)? = nil
    
    public init(completion: @escaping (String?, String?, ProcessOutException?) -> Void) {
        self.completion = completion
    }
    
    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        // No longer supported
    }

    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        // Nothing needed here
    }
}

//
//  ProcessOutWebView.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 30/09/2019.
//

import Foundation
import WebKit

public class ProcessOutWebView: WKWebView, WKNavigationDelegate, WKUIDelegate {

    private let REDIRECT_URL_PATTERN = "https:\\/\\/checkout\\.processout\\.(ninja|com)\\/helpers\\/mobile-processout-webview-landing.*"

    internal var onResult: (_ token: String) -> Void
    internal var onAuthenticationError: () -> Void
    
    public init(frame: CGRect, onResult: @escaping (String) -> Void, onAuthenticationError: @escaping () -> Void) {
        // Setup up the webview to display the challenge
        let config = WKWebViewConfiguration()
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        config.preferences = preferences
        
        self.onResult = onResult
        self.onAuthenticationError = onAuthenticationError
        super.init(frame: frame, configuration: config)
        self.customUserAgent = "ProcessOut iOS-Webview/" + type(of: ProcessOutApi.shared).version
        self.navigationDelegate = self
        self.uiDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onRedirect(url: URL) {
        fatalError("Must override onRedirect")
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else {
            return
        }
        
        if url.absoluteString.range(of: REDIRECT_URL_PATTERN, options: .regularExpression, range: nil, locale: nil) != nil {
         self.onRedirect(url: url)
        }
    }
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures)-> WKWebView? {
        // Add support for popups/new tabs
        webView.load(navigationAction.request)
        return nil
    }
}

extension URL {

    var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

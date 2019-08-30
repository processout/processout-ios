//
//  FingerPrintWebview.swift
//  Alamofire
//
//  Created by Jeremy Lejoux on 27/08/2019.
//

import Foundation
import WebKit
import UIKit

public class FingerPrintWebView: NSObject, WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
    
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
    {
        print(error)
    }
}

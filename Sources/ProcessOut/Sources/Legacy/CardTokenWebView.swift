//
//  CardTokenWebView.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 30/09/2019.
//

import Foundation

final class CardTokenWebView: ProcessOutWebView {
    
    override func onRedirect(url: URL) {
        guard let parameters = url.queryParameters, let token = parameters["token"] else {
            return
        }
        
        onResult(token)
    }
}

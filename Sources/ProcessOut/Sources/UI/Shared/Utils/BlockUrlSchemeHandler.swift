//
//  BlockUrlSchemeHandler.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.11.2022.
//

import WebKit

final class BlockUrlSchemeHandler: NSObject, WKURLSchemeHandler {

    init(start: @escaping (WKURLSchemeTask) -> Void, stop: ((WKURLSchemeTask) -> Void)? = nil) {
        self.start = start
        self.stop = stop
        super.init()
    }

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        start(urlSchemeTask)
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        stop?(urlSchemeTask)
    }

    // MARK: - Private Properties

    private let start: (WKURLSchemeTask) -> Void
    private let stop: ((WKURLSchemeTask) -> Void)?
}

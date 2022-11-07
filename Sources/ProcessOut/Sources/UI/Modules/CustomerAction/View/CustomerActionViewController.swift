//
//  CustomerActionViewController.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.11.2022.
//

import Foundation
import WebKit

final class CustomerActionViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    init(
        checkoutBaseUrl: URL,
        customerActionUrl: URL,
        version: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        self.checkoutBaseUrl = checkoutBaseUrl
        self.customerActionUrl = customerActionUrl
        self.version = version
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = contentView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let request = URLRequest(url: customerActionUrl)
        _ = contentView.load(request)
    }

    // MARK: - WKNavigationDelegate

    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let expectedPathPrefix = #"/helpers/mobile-processout-webview-landing"#
        guard let url = webView.url,
              let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let checkoutUrlComponent = URLComponents(url: checkoutBaseUrl, resolvingAgainstBaseURL: true),
              urlComponents.scheme == checkoutUrlComponent.scheme,
              urlComponents.host == checkoutUrlComponent.host,
              urlComponents.path.prefix(expectedPathPrefix.count) == expectedPathPrefix,
              let token = urlComponents.queryItems?.first(where: { $0.name == "token" }) else {
            return
        }
        webView.stopLoading()
        completion(.success(token.value ?? ""))
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.stopLoading()
        completion(.failure(error))
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webView.stopLoading()
        completion(.failure(error))
    }

    // MARK: - WKUIDelegate

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil
    }

    // MARK: - Private Properties

    private let checkoutBaseUrl: URL
    private let customerActionUrl: URL
    private let version: String
    private let completion: (Result<String, Error>) -> Void

    private lazy var contentView: WKWebView = {
        let view = WKWebView()
        view.customUserAgent = "ProcessOut iOS-Webview/" + version
        view.navigationDelegate = self
        view.uiDelegate = self
        view.allowsLinkPreview = false
        return view
    }()
}

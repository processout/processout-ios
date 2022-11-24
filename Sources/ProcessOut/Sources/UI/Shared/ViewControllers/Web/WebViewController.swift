//
//  WebViewController.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.11.2022.
//

import WebKit

final class WebViewController<Success>: UIViewController, WKNavigationDelegate, WKUIDelegate {

    init(
        delegate: any WebViewControllerDelegate<Success>,
        baseReturnUrl: URL,
        version: String,
        completion: ((Result<Success, PORepositoryFailure>) -> Void)?
    ) {
        self.delegate = delegate
        self.baseReturnUrl = baseReturnUrl
        self.version = version
        self.completion = completion
        state = .idle
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setStartingState()
    }

    // MARK: - WKNavigationDelegate

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        if setCompletedState(with: url) {
            decisionHandler(.cancel)
        } else if let scheme = url.scheme, !WKWebView.handlesURLScheme(scheme) {
            decisionHandler(.cancel)
            UIApplication.shared.open(url)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        if case let .starting(startingNavigation) = state, startingNavigation === navigation {
            state = .started
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        setCompletedState(with: error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        setCompletedState(with: error)
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

    // MARK: - Private Nested Types

    private enum State {

        /// Controller is currently idle and waiting for start.
        case idle

        /// Controller is being started.
        case starting(WKNavigation)

        /// Controller has been started and is currently operating.
        case started

        /// Controller did complete with either success or failure.
        case completed
    }

    // MARK: - Private Properties

    private let delegate: any WebViewControllerDelegate<Success>
    private let baseReturnUrl: URL
    private let version: String
    private let completion: ((Result<Success, PORepositoryFailure>) -> Void)?

    private lazy var contentViewConfiguration: WKWebViewConfiguration = {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.suppressesIncrementalRendering = true
        return configuration
    }()

    private lazy var contentView: WKWebView = {
        let view = WKWebView(frame: .zero, configuration: contentViewConfiguration)
        view.customUserAgent = "ProcessOut iOS-Webview/" + version
        view.navigationDelegate = self
        view.uiDelegate = self
        view.allowsLinkPreview = false
        view.allowsBackForwardNavigationGestures = false
        return view
    }()

    private var returnUrl: URL {
        baseReturnUrl.appendingPathComponent("helpers").appendingPathComponent("mobile-processout-webview-landing")
    }

    private var state: State

    // MARK: - State Management

    private func setStartingState() {
        guard case .idle = state else {
            return
        }
        let request = URLRequest(url: delegate.url)
        guard let navigation = contentView.load(request) else {
            let failure = PORepositoryFailure(message: nil, code: .internal, underlyingError: nil)
            setCompletedState(with: failure)
            return
        }
        state = .starting(navigation)
    }

    /// - Returns: `true` if state was set, `false` otherwise.
    private func setCompletedState(with url: URL) -> Bool {
        if case .completed = state {
            Logger.ui.error("Can't change state to completed because already in sink state.")
            return false
        }
        guard url.scheme == returnUrl.scheme, url.host == returnUrl.host, url.path == returnUrl.path else {
            return false
        }
        do {
            let response = try delegate.mapToSuccessValue(url: url)
            contentView.stopLoading()
            state = .completed
            completion?(.success(response))
        } catch {
            setCompletedState(with: error)
        }
        return true
    }

    private func setCompletedState(with error: Error) {
        if case .completed = state {
            Logger.ui.error("Can't change state to completed because already in sink state.")
            return
        }
        let failure: PORepositoryFailure
        if let error = error as? PORepositoryFailure {
            failure = error
        } else {
            failure = PORepositoryFailure(message: nil, code: .unknown, underlyingError: error)
        }
        contentView.stopLoading()
        state = .completed
        completion?(.failure(failure))
    }
}

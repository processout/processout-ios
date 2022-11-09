//
//  AlternativePaymentMethodViewController.swift
//  Example
//
//  Created by Andrii Vysotskyi on 07.11.2022.
//

import UIKit
import WebKit

final class AlternativePaymentMethodViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    init(
        alternativePaymentMethodsService: POAlternativePaymentMethodsServiceType,
        request: POAlternativePaymentMethodRequest,
        returnUrl: URL,
        completion: ((Result<POAlternativePaymentMethodResponse, PORepositoryFailure>) -> Void)?
    ) {
        self.alternativePaymentMethodsService = alternativePaymentMethodsService
        self.request = request
        self.returnUrl = returnUrl
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
        start()
    }

    // MARK: - WKNavigationDelegate

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let url = navigationAction.request.url, url.scheme == returnUrl.scheme, url.host == returnUrl.host {
            decisionHandler(.cancel)
            complete(with: url)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        guard case let .starting(startingNavigation) = state, startingNavigation === navigation else {
            return
        }
        state = .started
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        complete(with: error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        complete(with: error)
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
        case idle, starting(WKNavigation), started, failure
    }

    // MARK: - Private Properties

    private let alternativePaymentMethodsService: POAlternativePaymentMethodsServiceType
    private let request: POAlternativePaymentMethodRequest
    private let returnUrl: URL
    private let completion: ((Result<POAlternativePaymentMethodResponse, PORepositoryFailure>) -> Void)?

    private lazy var contentViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        attachCustomSchemeHandlerIfNeeded(configuration: configuration)
        return configuration
    }()

    private lazy var contentView: WKWebView = {
        let view = WKWebView(frame: .zero, configuration: contentViewConfiguration)
        view.navigationDelegate = self
        view.uiDelegate = self
        view.allowsLinkPreview = false
        view.allowsBackForwardNavigationGestures = false
        return view
    }()

    private var state: State

    // MARK: - Private Methods

    private func start() {
        guard case .idle = state else {
            return
        }
        let url = alternativePaymentMethodsService.alternativePaymentMethodUrl(request: request)
        let urlRequest = URLRequest(url: url)
        guard let navigation = contentView.load(urlRequest) else {
            assertionFailure("Failed to trigger request load.")
            return
        }
        state = .starting(navigation)
    }

    private func complete(with url: URL) {
        switch state {
        case .started, .starting:
            break
        default:
            Logger.ui.error("Invalid state.")
            return
        }
        contentView.stopLoading()
        do {
            let response = try alternativePaymentMethodsService.alternativePaymentMethodResponse(url: url)
            completion?(.success(response))
        } catch let failure as PORepositoryFailure {
            state = .failure
            completion?(.failure(failure))
        } catch {
            complete(with: error)
        }
    }

    private func complete(with error: Error) {
        state = .failure
        let failure = PORepositoryFailure(message: nil, code: .unknown, underlyingError: error)
        completion?(.failure(failure))
    }

    private func attachCustomSchemeHandlerIfNeeded(configuration: WKWebViewConfiguration) {
        guard let scheme = returnUrl.scheme, !WKWebView.handlesURLScheme(scheme) else {
            return
        }
        let schemeHandler = BlockUrlSchemeHandler { [weak self] task in
            guard let taskUrl = task.request.url else {
                return
            }
            if let urlResponse = HTTPURLResponse(url: taskUrl, statusCode: 200, httpVersion: nil, headerFields: nil) {
                task.didReceive(urlResponse)
            }
            task.didFinish()
            self?.complete(with: taskUrl)
        }
        configuration.setURLSchemeHandler(schemeHandler, forURLScheme: scheme)
    }
}

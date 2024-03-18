//
//  SFSafariViewController+3DSRedirect.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.11.2023.
//

import SafariServices
@_spi(PO) import ProcessOut

extension SFSafariViewController {

    /// Creates view controller that can handle 3DS Redirects.
    /// 
    /// - Note: Caller should dismiss view controller after completion is called.
    /// - Note: Object's delegate shouldn't be modified.
    ///
    /// - Parameters:
    ///   - redirect: redirect to handle.
    ///   - returnUrl: Return URL specified when creating invoice or customer token.
    ///   - safariConfiguration: The configuration for the new view controller.
    ///   - completion: Completion to invoke when redirect handling ends.
    public convenience init(
        redirect: PO3DSRedirect,
        returnUrl: URL,
        safariConfiguration: SFSafariViewController.Configuration = .init(),
        completion: @escaping (Result<String, POFailure>) -> Void
    ) {
        self.init(url: redirect.url, configuration: safariConfiguration)
        let api: ProcessOut = ProcessOut.shared // swiftlint:disable:this redundant_type_annotation
        let viewModel = DefaultSafariViewModel(
            configuration: .init(returnUrl: returnUrl, timeout: redirect.timeout),
            eventEmitter: api.eventEmitter,
            logger: api.logger,
            completion: { [weak self] result in
                self?.complete(completion, with: result)
            }
        )
        setViewModel(viewModel)
        viewModel.start()
    }

    // MARK: - Private Nested Types

    private typealias Completion = (Result<String, POFailure>) -> Void

    private enum Constants {
        static let tokenQueryItemName = "token"
    }

    // MARK: - Private Methods

    private func complete(_ completion: @escaping Completion, with result: Result<URL, POFailure>) {
        let mappedResult = result.flatMap { url -> Result<String, POFailure> in
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                let failure = POFailure(message: nil, code: .internal(.mobile))
                return .failure(failure)
            }
            let token = components.queryItems?.first { $0.name == Constants.tokenQueryItemName }?.value
            return .success(token ?? "")
        }
        completion(mappedResult)
    }
}

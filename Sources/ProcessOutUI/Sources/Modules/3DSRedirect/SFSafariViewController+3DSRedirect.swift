//
//  SFSafariViewController+3DSRedirect.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.11.2023.
//

import SafariServices
@_spi(PO) import ProcessOut

@available(*, deprecated, message: "Redirects are handled internally.")
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
            callback: .customScheme(returnUrl.scheme ?? ""),
            timeout: redirect.timeout,
            eventEmitter: api.eventEmitter,
            logger: api.logger,
            completion: { result in
                completion(result.map(Self.token(with:)))
            }
        )
        setViewModel(viewModel)
        viewModel.start()
    }

    // MARK: - Private Methods

    private static func token(with url: URL) -> String {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        return components?.queryItems?.first { $0.name == "token" }?.value ?? ""
    }
}

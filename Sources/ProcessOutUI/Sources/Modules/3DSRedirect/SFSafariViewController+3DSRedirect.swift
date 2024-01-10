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
        let delegate = ThreeDSRedirectSafariViewModelDelegate(completion: completion)
        let configuration = DefaultSafariViewModelConfiguration(
            returnUrl: returnUrl, timeout: redirect.timeout
        )
        let viewModel = DefaultSafariViewModel(
            configuration: configuration, eventEmitter: api.eventEmitter, logger: api.logger, delegate: delegate
        )
        self.delegate = viewModel
        setViewModel(viewModel)
        viewModel.start()
    }
}

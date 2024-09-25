//
//  SafariViewController+Extensions.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

import SafariServices

@available(*, deprecated, message: "Web authentications are handled internally.")
extension SFSafariViewController {

    func setViewModel(_ viewModel: DefaultSafariViewModel) {
        objc_setAssociatedObject(self, &Keys.viewModel, viewModel, .OBJC_ASSOCIATION_RETAIN)
        delegate = viewModel
    }

    // MARK: - Private Nested Types

    private enum Keys {
        static var viewModel: UInt8 = 0
    }
}

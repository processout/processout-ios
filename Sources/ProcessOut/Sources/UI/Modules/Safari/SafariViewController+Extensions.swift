//
//  SafariViewController+Extensions.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

import SafariServices

@available(*, deprecated)
extension SFSafariViewController {

    func setViewModel(_ viewModel: DefaultSafariViewModel) {
        objc_setAssociatedObject(self, &Keys.viewModel, viewModel, .OBJC_ASSOCIATION_RETAIN)
    }

    // MARK: - Private Nested Types

    @MainActor
    private enum Keys {
        static var viewModel: UInt8 = 0
    }
}

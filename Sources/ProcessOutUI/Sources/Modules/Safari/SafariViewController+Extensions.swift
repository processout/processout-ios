//
//  SafariViewController+Extensions.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

import SafariServices

extension SFSafariViewController {

    func setViewModel(_ viewModel: DefaultSafariViewModel) {
        objc_setAssociatedObject(self, &Keys.viewModel, viewModel, .OBJC_ASSOCIATION_RETAIN)
    }

    // MARK: - Private Nested Types

    private enum Keys {
        static var viewModel: UInt8 = 0
    }
}

//
//  POStringResource+Extension.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 31.01.2024.
//

@_spi(PO) import ProcessOut

extension POStringResource {

    init(_ key: String, comment: String) {
        self.init(key, bundle: BundleLocator.bundle, comment: comment)
    }
}

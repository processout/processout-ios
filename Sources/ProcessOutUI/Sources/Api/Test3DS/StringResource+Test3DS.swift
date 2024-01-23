//
//  StringResource+Test3DS.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 21.11.2023.
//

@_spi(PO) import ProcessOut

extension POStringResource {

    enum Test3DS {

        /// 3DS challenge title.
        static let title = POStringResource("test-3ds.challenge.title", comment: "")

        /// Accept button title.
        static let accept = POStringResource("test-3ds.challenge.accept", comment: "")

        /// Reject button title.
        static let reject = POStringResource("test-3ds.challenge.reject", comment: "")
    }
}

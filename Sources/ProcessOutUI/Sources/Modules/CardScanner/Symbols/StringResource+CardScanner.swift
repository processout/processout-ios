//
//  StringResource+CardScanner.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.11.2024.
//

@_spi(PO) import ProcessOut

extension POStringResource {

    enum CardScanner {

        /// Card scanner title.
        static let title = POStringResource("card-scanner.title", comment: "")

        /// Card scanner description.
        static let description = POStringResource("card-scanner.description", comment: "")
    }
}

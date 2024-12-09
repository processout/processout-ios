//
//  LocalizedStringResource+CardScanner.swift
//  Example
//
//  Created by Andrii Vysotskyi on 03.12.2024.
//

import Foundation

extension LocalizedStringResource {

    enum CardScanner {

        /// Title.
        static let title = LocalizedStringResource("card-scanner.title")

        /// Pay button.
        static let scan = LocalizedStringResource("card-scanner.scan")

        /// Success message.
        static let successMessage = LocalizedStringResource(
            "card-scanner.success-message-\(placeholder: .object)-\(placeholder: .object)-\(placeholder: .object)"
        )

        /// Error message.
        static let errorMessage = LocalizedStringResource("card-scanner.error-message")
    }
}

//
//  AlternativePaymentDataEntryBuilder.swift
//  Example
//
//  Created by Andrii Vysotskyi on 26.01.2023.
//

import UIKit

@MainActor
final class AlternativePaymentDataEntryBuilder {

    init(completion: @escaping (_ key: String, _ value: String) -> Void) {
        self.completion = completion
    }

    func build() -> UIViewController {
        let viewController = UIAlertController(
            title: nil, message: String(localized: .AlternativePaymentDataEntry.message), preferredStyle: .alert
        )
        viewController.addTextField { textField in
            textField.placeholder = String(localized: .AlternativePaymentDataEntry.key)
            textField.keyboardType = .asciiCapable
        }
        viewController.addTextField { textField in
            textField.placeholder = String(localized: .AlternativePaymentDataEntry.value)
            textField.keyboardType = .asciiCapable
        }
        let submitAction = UIAlertAction(
            title: String(localized: .AlternativePaymentDataEntry.confirm),
            style: .default,
            handler: { [weak viewController, completion] _ in
                let textFields = viewController?.textFields ?? []
                let key = textFields[0].text ?? ""
                let value = textFields[1].text ?? ""
                completion(key, value)
            }
        )
        viewController.addAction(submitAction)
        return viewController
    }

    // MARK: - Private Properties

    private let completion: (_ key: String, _ value: String) -> Void
}

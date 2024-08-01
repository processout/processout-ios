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
            title: nil, message: Strings.AlternativePaymentDataEntry.message, preferredStyle: .alert
        )
        viewController.addTextField { textField in
            textField.placeholder = Strings.AlternativePaymentDataEntry.Key.placeholder
            textField.keyboardType = .asciiCapable
        }
        viewController.addTextField { textField in
            textField.placeholder = Strings.AlternativePaymentDataEntry.Value.placeholder
            textField.keyboardType = .asciiCapable
        }
        let submitAction = UIAlertAction(
            title: Strings.AlternativePaymentDataEntry.confirm,
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

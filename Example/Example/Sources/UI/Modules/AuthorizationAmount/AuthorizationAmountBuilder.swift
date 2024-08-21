//
//  AuthorizationAmountBuilder.swift
//  Example
//
//  Created by Andrii Vysotskyi on 09.11.2022.
//

import UIKit

@MainActor
final class AuthorizationAmountBuilder {

    init(completion: @escaping (_ amount: Decimal, _ currencyCode: String) -> Void) {
        self.completion = completion
    }

    func build() -> UIViewController {
        let viewController = UIAlertController(
            title: nil, message: String(localized: .AuthorizationAmount.message), preferredStyle: .alert
        )
        viewController.addTextField { textField in
            textField.placeholder = String(localized: .AuthorizationAmount.amount)
            textField.keyboardType = .decimalPad
            textField.autocorrectionType = .no
            textField.accessibilityIdentifier = "authorization-amount.amount"
        }
        viewController.addTextField { textField in
            textField.placeholder = String(localized: .AuthorizationAmount.currency)
            textField.keyboardType = .alphabet
            textField.autocorrectionType = .no
            textField.accessibilityIdentifier = "authorization-amount.currency"
        }
        let submitAction = UIAlertAction(
            title: String(localized: .AuthorizationAmount.confirm),
            style: .default,
            handler: { [weak viewController, completion] _ in
                let textFields = viewController?.textFields ?? []
                let amount = Decimal(string: textFields[0].text ?? "") ?? .zero
                let currencyCode = textFields[1].text ?? ""
                completion(amount, currencyCode)
            }
        )
        submitAction.accessibilityIdentifier = "authorization-amount.confirm"
        viewController.addAction(submitAction)
        return viewController
    }

    // MARK: - Private Properties

    private let completion: (_ amount: Decimal, _ currencyCode: String) -> Void
}

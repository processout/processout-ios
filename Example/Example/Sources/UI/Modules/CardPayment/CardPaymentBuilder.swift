//
//  CardPaymentBuilder.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.03.2023.
//

import UIKit
import ProcessOut
import ProcessOutUI

final class CardPaymentBuilder {

    init(completion: @escaping (Result<POCard, POFailure>) -> Void) {
        self.completion = completion
    }

    func build() -> UIViewController {
        // todo(andrii-vysotskyi): authorize tokenized card
        let configuration = POCardTokenizationConfiguration(isCardholderNameInputVisible: false)
        let viewController = POCardTokenizationViewController(
            configuration: configuration, completion: completion
        )
        return viewController
    }

    // MARK: - Private Properties

    private let completion: (Result<POCard, POFailure>) -> Void
}

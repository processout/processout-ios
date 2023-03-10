//
//  CardPaymentBuilder.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.03.2023.
//

import UIKit

final class CardPaymentBuilder {

    func build() -> UIViewController {
        let viewModel = CardPaymentViewModel(state: .idle)
        let viewController = CardPaymentViewController(viewModel: viewModel)
        viewModel.viewController = viewController
        return viewController
    }
}

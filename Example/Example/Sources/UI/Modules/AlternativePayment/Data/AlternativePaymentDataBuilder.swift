//
//  AlternativePaymentDataBuilder.swift
//  Example
//
//  Created by Andrii Vysotskyi on 25.01.2023.
//

import UIKit

@MainActor
final class AlternativePaymentDataBuilder {

    init(completion: @escaping ([String: String]) -> Void) {
        self.completion = completion
    }

    func build() -> UIViewController {
        let router = AlternativePaymentDataRouter()
        let viewModel = AlternativePaymentDataViewModel(router: router, completion: completion)
        let viewController = AlternativePaymentDataViewController(viewModel: viewModel)
        router.viewController = viewController
        return viewController
    }

    // MARK: - Private Properties

    private let completion: ([String: String]) -> Void
}

//
//  FeaturesBuilder.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

import UIKit
import ProcessOut

final class FeaturesBuilder {

    func build() -> UIViewController {
        let router = FeaturesRouter()
        let viewModel = FeaturesViewModel(
            invoicesService: ProcessOut.shared.invoices, router: router
        )
        let viewController = FeaturesViewController(viewModel: viewModel)
        router.viewController = viewController
        return viewController
    }
}

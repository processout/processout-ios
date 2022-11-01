//
//  FeaturesBuilder.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

import UIKit

final class FeaturesBuilder {

    func build() -> UIViewController {
        let router = FeaturesRouter()
        let viewModel = FeaturesViewModel(router: router)
        let viewController = FeaturesViewController(viewModel: viewModel)
        router.viewController = viewController
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }
}

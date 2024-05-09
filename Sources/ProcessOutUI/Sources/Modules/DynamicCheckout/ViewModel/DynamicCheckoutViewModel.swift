//
//  DynamicCheckoutViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import Combine
@_spi(PO) import ProcessOutCoreUI

protocol DynamicCheckoutViewModel: ObservableObject {

    /// Available sections.
    var state: DynamicCheckoutViewModelState { get }

    /// Starts view model.
    func start()
}

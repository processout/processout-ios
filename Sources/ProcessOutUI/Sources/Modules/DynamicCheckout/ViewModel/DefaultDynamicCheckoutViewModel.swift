//
//  DefaultDynamicCheckoutViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import Foundation
@_spi(PO) import ProcessOutCoreUI

final class DefaultDynamicCheckoutViewModel: DynamicCheckoutViewModel {

    // MARK: - DynamicCheckoutViewModel

    @Published
    private(set) var sections: [DynamicCheckoutViewModelSection] = []

    @Published
    private(set) var actions: [POActionsContainerActionViewModel] = []
}

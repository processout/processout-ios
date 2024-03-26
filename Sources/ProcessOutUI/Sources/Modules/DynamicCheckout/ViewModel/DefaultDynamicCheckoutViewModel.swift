//
//  DefaultDynamicCheckoutViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import Foundation
@_spi(PO) import ProcessOutCoreUI

final class DefaultDynamicCheckoutViewModel: DynamicCheckoutViewModel {

    init(interactor: some DynamicCheckoutInteractor) {
        self.interactor = interactor
        observeChanges(interactor: interactor)
    }

    // MARK: - DynamicCheckoutViewModel

    @Published
    private(set) var sections: [DynamicCheckoutViewModelSection] = []

    @Published
    private(set) var actions: [POActionsContainerActionViewModel] = []

    // MARK: - Private Properties

    private let interactor: any DynamicCheckoutInteractor

    // MARK: - Private Methods

    private func observeChanges(interactor: some Interactor) {
        interactor.start()
        interactor.didChange = { [weak self] in
            self?.updateWithInteractorState()
        }
    }

    private func updateWithInteractorState() {
        // TBD
    }
}

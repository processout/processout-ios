//
//  AlternativePaymentsViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import Foundation
import Combine
import ProcessOut
import ProcessOutUI

@MainActor
final class AlternativePaymentsViewModel: ObservableObject {

    init(interactor: AlternativePaymentsInteractor) {
        self.interactor = interactor
        cancellables = []
        observeInteractorStateChanges()
    }

    // MARK: - AlternativePaymentsViewModel

    @Published
    var state = AlternativePaymentsViewModelState()

    func start() {
        Task {
            await interactor.start()
        }
    }

    func restart() async {
        state.message = nil
        await interactor.restart()
    }

    func pay() {
        Task {
            await startPayment()
        }
        state.message = nil
    }

    // MARK: - Private Properties

    private let interactor: AlternativePaymentsInteractor
    private var cancellables: Set<AnyCancellable>

    // MARK: - Private Methods

    private func observeInteractorStateChanges() {
        let cancellable = interactor.$state.sink { [weak self] state in
            self?.update(with: state)
        }
        cancellables.insert(cancellable)
    }

    private func update(with interactorState: AlternativePaymentsInteractorState) {
        // TBD
    }

    private func startPayment() async {
       // TBD
    }
}

extension AlternativePaymentsViewModel {

    /// Convenience initializer that resolves its dependencies automatically.
    convenience init() {
        let interactor = AlternativePaymentsInteractor(
            gatewayConfigurationsRepository: ProcessOut.shared.gatewayConfigurations,
            invoicesService: ProcessOut.shared.invoices
        )
        self.init(interactor: interactor)
    }
}

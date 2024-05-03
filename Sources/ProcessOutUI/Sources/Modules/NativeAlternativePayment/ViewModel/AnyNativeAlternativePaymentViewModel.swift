//
//  AnyNativeAlternativePaymentViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import Combine
@_spi(PO) import ProcessOutCoreUI

final class AnyNativeAlternativePaymentViewModel: NativeAlternativePaymentViewModel {

    init<ViewModel: NativeAlternativePaymentViewModel>(erasing viewModel: ViewModel) {
        self.base = viewModel
        cancellable = viewModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    let base: any NativeAlternativePaymentViewModel

    // MARK: - CardUpdateViewModel

    var sections: [NativeAlternativePaymentViewModelSection] {
        base.sections
    }

    var actions: [POActionsContainerActionViewModel] {
        base.actions
    }

    var focusedItemId: AnyHashable? {
        get { base.focusedItemId }
        set { base.focusedItemId = newValue }
    }

    var isCaptured: Bool {
        base.isCaptured
    }

    func start() {
        base.start()
    }

    // MARK: - Private Properties

    private var cancellable: AnyCancellable?
}

//
//  BaseViewController.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2023.
//

import UIKit

class BaseViewController<ViewModel>: UIViewController where ViewModel: ProcessOut.ViewModel {

    init(viewModel: ViewModel, logger: POLogger) {
        self.viewModel = viewModel
        self.logger = logger
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.didChange = { [weak self] in self?.viewModelDidChange() }
        viewModel.start()
    }

    // MARK: -

    func configure(with state: ViewModel.State) {
        logger.debug("Will update view with new state: \(String(describing: state))")
    }

    let viewModel: ViewModel

    // MARK: - Private Properties

    private let logger: POLogger

    // MARK: - Private Methods

    private func viewModelDidChange() {
        // There may be UI glitches if view is updated when being tracked by user. So
        // as a workaround, configuration is postponed to a point when tracking ends.
        if RunLoop.current.currentMode == .tracking {
            RunLoop.current.perform {
                self.configure(with: self.viewModel.state)
            }
        } else {
            configure(with: viewModel.state)
        }
    }
}

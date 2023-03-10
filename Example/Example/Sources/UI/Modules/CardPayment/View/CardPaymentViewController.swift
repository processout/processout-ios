//
//  CardPaymentViewController.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.03.2023.
//

import UIKit
import SnapKit

final class CardPaymentViewController <ViewModel: CardPaymentViewModelType>: ViewController<ViewModel> {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configure()
    }

    // MARK: - Private Properties

    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pay", for: .normal)
        button.addTarget(self, action: #selector(didTouchPayButton), for: .touchUpInside)
        return button
    }()

    // MARK: - Private Methods

    private func configure() {
        view.addSubview(payButton)
        payButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view).inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            make.centerY.equalTo(view)
        }
    }

    @objc
    private func didTouchPayButton() {
        viewModel.pay()
    }
}

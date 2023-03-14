//
//  CardPaymentParameterCell.swift
//  Example
//
//  Created by Andrii Vysotskyi on 14.03.2023.
//

import UIKit

final class CardPaymentParameterCell: UICollectionViewListCell {

    typealias CellRegistration =
        UICollectionView.CellRegistration<CardPaymentParameterCell, CardPaymentViewModelState.Parameter>

    static let registration = CellRegistration { cell, _, model in
        cell.contentConfiguration = ContentViewConfiguration(model: model)
    }
}

private final class ContentView: UIView, UIContentView {

    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var configuration: UIContentConfiguration {
        didSet { configure(oldConfiguration: oldValue) }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Constants.height)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let height: CGFloat = 44
        static let contentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    // MARK: - Private Properties

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        return textField
    }()

    private var observer: AnyObject?

    // MARK: - Private Methods

    private func configure(oldConfiguration: UIContentConfiguration) {
        if let configuration = configuration as? ContentViewConfiguration {
            observer = configuration.model.$value.addObserver { [weak self] newValue in
                if self?.textField.text != newValue {
                    self?.textField.text = newValue
                }
            }
            textField.text = configuration.model.value
            textField.placeholder = configuration.model.placeholder
            textField.accessibilityIdentifier = configuration.model.accessibilityId
        }
    }

    private func commonInit() {
        addSubview(textField)
        textField.snp.makeConstraints { $0.edges.equalToSuperview().inset(Constants.contentInsets) }
    }

    @objc
    private func textFieldEditingChanged() {
        let configuration = configuration as? ContentViewConfiguration
        configuration?.model.value = textField.text ?? ""
    }
}

private struct ContentViewConfiguration: UIContentConfiguration {

    /// Model.
    let model: CardPaymentViewModelState.Parameter

    func makeContentView() -> UIView & UIContentView {
        ContentView(self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        self
    }
}

//
//  NativeAlternativePaymentMethodViewController.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.10.2022.
//

import UIKit

final class NativeAlternativePaymentMethodViewController: UIViewController {

    init(viewModel: any NativeAlternativePaymentMethodViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        let constraints = [
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.start()
        viewModel.didChange = { [weak self] in self?.configureWithViewModelState() }
    }

    // MARK: - Private Properties

    private let viewModel: any NativeAlternativePaymentMethodViewModelType

    private lazy var contentView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            titleLabel, submitButton
        ])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .fill
        view.spacing = 16
        view.axis = .vertical
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(didTouchSubmitButton), for: .touchUpInside)
        return button
    }()

    private var parameterTextFields: [UITextField] = []
    private var parameters: [NativeAlternativePaymentMethodViewModelState.Parameter] = []

    // MARK: - State Management

    private func configureWithViewModelState() {
        switch viewModel.state {
        case .idle:
            configureWithIdleState()
        case .starting:
            configureWithStartingState()
        case .started(let startedState):
            configureWithStartedState(startedState: startedState)
        case .failure:
            configureWithFailureState()
        }
    }

    private func configureWithIdleState() {
        contentView.isHidden = true
    }

    private func configureWithStartingState() {
        contentView.isHidden = true
    }

    private func configureWithStartedState(startedState: NativeAlternativePaymentMethodViewModelState.Started) {
        contentView.isHidden = false
        titleLabel.text = startedState.message
        titleLabel.isHidden = startedState.message != nil
        submitButton.isEnabled = startedState.isSubmitAllowed
        configureParameterTextFields(startedState: startedState)
    }

    private func configureWithFailureState() {
        contentView.isHidden = true
    }

    // MARK: -

    private func configureParameterTextFields(startedState: NativeAlternativePaymentMethodViewModelState.Started) {
        if parameterTextFields.count < startedState.parameters.count {
            let count = startedState.parameters.count - parameterTextFields.count
            stride(from: 0, to: count, by: 1).forEach { _ in
                let textField = UITextField()
                textField.translatesAutoresizingMaskIntoConstraints = false
                textField.addTarget(self, action: #selector(textFieldValueChanged(textField:)), for: .editingChanged)
                parameterTextFields.append(textField)
            }
        } else {
            let count = parameterTextFields.count - startedState.parameters.count
            parameterTextFields.suffix(count).forEach { textField in
                textField.removeFromSuperview()
            }
        }
        startedState.parameters.enumerated().forEach { parameter in
            let textField = parameterTextFields[parameter.offset]
            configureTextField(textField, parameter: parameter.element)
        }
        parameters = startedState.parameters
    }

    private func configureTextField(
        _ textField: UITextField, parameter: NativeAlternativePaymentMethodViewModelState.Parameter
    ) {
        textField.placeholder = parameter.placeholder
        textField.text = parameter.value
        switch parameter.type {
        case .numeric:
            textField.keyboardType = .numberPad
        case .text:
            textField.keyboardType = .asciiCapable
        case .email:
            textField.keyboardType = .emailAddress
        case .phone:
            textField.keyboardType = .phonePad
        }
    }

    // MARK: - Actions

    @objc
    private func didTouchSubmitButton() {
        viewModel.submit()
    }

    @objc
    private func textFieldValueChanged(textField: UITextField) {
        guard let index = parameterTextFields.firstIndex(of: textField) else {
            return
        }
        _ = parameters[index].update(textField.text ?? "")
    }
}

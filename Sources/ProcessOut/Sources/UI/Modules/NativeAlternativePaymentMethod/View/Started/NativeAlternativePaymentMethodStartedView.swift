//
//  NativeAlternativePaymentMethodStartedView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.12.2022.
//

import UIKit

final class NativeAlternativePaymentMethodStartedView: UIView { // swiftlint:disable:this type_body_length

    init(style: NativeAlternativePaymentMethodStartedViewStyle) {
        self.style = style
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with state: NativeAlternativePaymentMethodViewModelState.Started, animated: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) { [self] in
            CATransaction.begin()
            CATransaction.setDisableActions(!animated)
            titleLabel.attributedText = AttributedStringBuilder()
                .typography(style.title.typography)
                .alignment(.center)
                .lineBreakMode(.byWordWrapping)
                .textColor(style.title.color)
                .string(state.title)
                .build()
            if areInputFormViewsValid(for: state.parameters) {
                configureExistingInputFormViews(parameters: state.parameters, animated: animated)
            } else {
                createNewInputFormViews(parameters: state.parameters)
            }
            let primaryButtonViewModel = Button.ViewModel(
                title: state.action.title, isLoading: state.isSubmitting, handler: state.action.handler
            )
            primaryButton.configure(viewModel: primaryButtonViewModel, animated: animated)
            primaryButton.isEnabled = state.action.isEnabled
            setNeedsLayout()
            layoutIfNeeded()
            CATransaction.commit()
        }
        currentState = state
        updateFirstResponder()
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let additionalBottomScrollContentInset: CGFloat = 48 + verticalButtonInset * 2
        static let inputsVerticalSpacing: CGFloat = 24
        static let maximumCodeLength = 6
        static let verticalButtonInset: CGFloat = 24
        static let horizontalContentInset: CGFloat = 24
        static let minimumVerticalInputsInset: CGFloat = 8
        static let animationDuration: TimeInterval = 0.25
    }

    // MARK: - Private Properties

    private let style: NativeAlternativePaymentMethodStartedViewStyle

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentInsetAdjustmentBehavior = .always
        view.contentInset.bottom = Constants.additionalBottomScrollContentInset
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = false
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private lazy var inputsContainerView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = Constants.inputsVerticalSpacing
        view.axis = .vertical
        return view
    }()

    private lazy var primaryButton = Button(style: style.primaryButton)

    private var inputFormViews: [InputFormView] {
        // swiftlint:disable:next force_cast
        inputsContainerView.arrangedSubviews as! [InputFormView]
    }

    private var currentState: NativeAlternativePaymentMethodViewModelState.Started?

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        initScrollView()
        initScrollViewContentView()
        addSubview(primaryButton)
        let constraints = [
            primaryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalContentInset),
            primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            primaryButton.bottomAnchor
                .constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.verticalButtonInset)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func initScrollView() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        let constraints = [
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor
                .constraint(
                    equalTo: scrollView.safeAreaLayoutGuide.heightAnchor,
                    constant: -Constants.additionalBottomScrollContentInset
                )
                .with(priority: .defaultHigh)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func initScrollViewContentView() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(inputsContainerView)
        let constraints = [
            titleLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: contentView.leadingAnchor, constant: Constants.horizontalContentInset
            ),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            inputsContainerView.topAnchor.constraint(
                greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: Constants.minimumVerticalInputsInset
            ),
            inputsContainerView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: Constants.horizontalContentInset
            ),
            inputsContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            inputsContainerView.centerYAnchor
                .constraint(equalTo: contentView.centerYAnchor)
                .with(priority: .init(rawValue: 50)),
            inputsContainerView.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor, constant: -Constants.minimumVerticalInputsInset
            )
        ]
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Input Forms Configuration

    /// Returns boolean value that indicates whether input forms are valid for given parameters. When method
    /// returns `false` make sure to recreate input fields from scratch.
    private func areInputFormViewsValid(
        for parameters: [NativeAlternativePaymentMethodViewModelState.Parameter]
    ) -> Bool {
        currentState?.parameters.map(shouldUseCodeTextField) == parameters.map(shouldUseCodeTextField)
    }

    private func shouldUseCodeTextField(for parameter: NativeAlternativePaymentMethodViewModelState.Parameter) -> Bool {
        if let length = parameter.length,
           length <= Constants.maximumCodeLength,
           [.numeric, .text].contains(parameter.type) {
            return true
        }
        return false
    }

    private func createNewInputFormViews(parameters: [NativeAlternativePaymentMethodViewModelState.Parameter]) {
        inputFormViews.forEach { view in
            view.removeFromSuperview()
        }
        parameters.enumerated().forEach { offset, parameter in
            let isLastParameter = offset + 1 == parameters.count
            let inputFormView: InputFormView
            if let length = parameter.length, shouldUseCodeTextField(for: parameter) {
                let codeTextField = CodeTextField(length: length)
                codeTextField.delegate = self
                codeTextField.returnKeyType = isLastParameter ? .done : .next
                inputFormView = InputFormView(textField: codeTextField, style: style.codeInput)
            } else {
                let containerView = TextFieldContainerView()
                containerView.textField.delegate = self
                containerView.textField.returnKeyType = isLastParameter ? .done : .next
                inputFormView = InputFormView(textField: containerView, style: style.input)
            }
            inputFormView.textField.control.addTarget(
                self, action: #selector(controlEditingDidChange), for: .editingChanged
            )
            inputsContainerView.addArrangedSubview(inputFormView)
        }
        verticallyCenterInputFormViews()
        configureExistingInputFormViews(parameters: parameters, animated: false)
    }

    /// Method adds constraints to make sure that center point between first input form's top edge and last input form
    /// text field's bottom edge is located in between title's bottom edge and action button's top edge.
    private func verticallyCenterInputFormViews() {
        guard let firstInputFormView = inputFormViews.first, let lastInputFormView = inputFormViews.last else {
            return
        }
        let containerLayoutGuide = UILayoutGuide()
        let inputsLayoutGuide = UILayoutGuide()
        contentView.addLayoutGuide(containerLayoutGuide)
        inputsContainerView.addLayoutGuide(inputsLayoutGuide)
        let constraints = [
            containerLayoutGuide.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            containerLayoutGuide.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: Constants.verticalButtonInset
            ),
            inputsLayoutGuide.topAnchor.constraint(equalTo: firstInputFormView.topAnchor),
            inputsLayoutGuide.bottomAnchor.constraint(equalTo: lastInputFormView.textField.bottomAnchor),
            inputsLayoutGuide.centerYAnchor
                .constraint(equalTo: containerLayoutGuide.centerYAnchor).with(priority: .init(rawValue: 500))
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func configureExistingInputFormViews(
        parameters: [NativeAlternativePaymentMethodViewModelState.Parameter], animated: Bool
    ) {
        inputFormViews.enumerated().forEach { offset, inputFormView in
            let parameter = parameters[offset]
            if let textField = inputFormView.textField as? CodeTextField {
                textField.text = parameter.value
                textField.keyboardType = keyboardType(for: parameter.type)
                textField.textContentType = textContentType(for: parameter.type)
            } else if let containerView = inputFormView.textField as? TextFieldContainerView {
                containerView.textField.text = parameter.value
                containerView.textField.placeholder = parameter.placeholder
                containerView.textField.keyboardType = keyboardType(for: parameter.type)
                containerView.textField.textContentType = textContentType(for: parameter.type)
            }
            let inputFormViewModel = InputFormView.ViewModel(
                title: parameter.name, description: parameter.errorMessage, isInError: parameter.errorMessage != nil
            )
            inputFormView.configure(viewModel: inputFormViewModel, animated: animated)
        }
    }

    private func keyboardType(
        for parameterType: NativeAlternativePaymentMethodViewModelState.ParameterType
    ) -> UIKeyboardType {
        let keyboardTypes: [NativeAlternativePaymentMethodViewModelState.ParameterType: UIKeyboardType] = [
            .text: .asciiCapable, .email: .emailAddress, .numeric: .numberPad, .phone: .phonePad
        ]
        return keyboardTypes[parameterType] ?? .default
    }

    private func textContentType(
        for parameterType: NativeAlternativePaymentMethodViewModelState.ParameterType
    ) -> UITextContentType? {
        switch parameterType {
        case .text:
            return nil
        case .email:
            return .emailAddress
        case .numeric:
            if #available(iOS 12.0, *) {
                return .oneTimeCode
            }
        case .phone:
            return .telephoneNumber
        }
        return nil
    }

    // MARK: -

    private func updateFirstResponder() {
        guard let currentState else {
            return
        }
        if currentState.isSubmitting {
            endEditing(true)
        } else if !inputFormViews.contains(where: { $0.textField.control.isFirstResponder }) {
            inputFormViews.first?.textField.control.becomeFirstResponder()
        }
    }

    private func advanceFirstResponderToNextInput(control: UIControl) {
        guard let index = inputFormViews.firstIndex(where: { $0.textField.control === control }) else {
            return
        }
        let nextIndex = index + 1
        if inputFormViews.indices.contains(nextIndex) {
            inputFormViews[nextIndex].textField.control.becomeFirstResponder()
        } else {
            currentState?.action.handler()
        }
    }

    // MARK: - Actions

    @objc
    private func controlEditingDidChange(_ control: UIControl) {
        guard let index = inputFormViews.firstIndex(where: { $0.textField.control === control }),
              let parameters = currentState?.parameters,
              parameters.indices.contains(index) else {
            return
        }
        let text: String?
        if let codeTextField = control as? CodeTextField {
            text = codeTextField.text
        } else if let textField = control as? UITextField {
            text = textField.text
        } else {
            return
        }
        parameters[index].update(text ?? "")
    }
}

extension NativeAlternativePaymentMethodStartedView: CodeTextFieldDelegate {

    func codeTextFieldShouldBeginEditing(_ textField: CodeTextField) -> Bool {
        currentState?.isSubmitting == false
    }

    func codeTextFieldShouldReturn(_ textField: CodeTextField) -> Bool {
        advanceFirstResponderToNextInput(control: textField)
        return true
    }
}

extension NativeAlternativePaymentMethodStartedView: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentState?.isSubmitting == false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        advanceFirstResponderToNextInput(control: textField)
        return true
    }
}

//
//  InputFormView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.11.2022.
//

import UIKit

final class InputFormView: UIView {

    struct ViewModel {

        /// Title.
        let title: String

        /// Description.
        let description: String?

        /// Placeholder.
        let placeholder: String?

        /// Inputs length limit.
        let length: Int?

        /// Boolean flag indicating whether input is currently in error state.
        let isInError: Bool
    }

    // MARK: -

    init(style: POInputFormStyle) {
        self.style = style
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var forLastBaselineLayout: UIView {
        inputContainerView
    }

    /// - NOTE: If view model's length is different from previously set value, `textField` will be replaced
    /// with different value so make sure to configure it appropriately after method completes.
    func configure(viewModel: ViewModel, animated: Bool) {
        if animated {
            UIView.transition(
                with: self,
                duration: Constants.animationDuration,
                options: [.transitionCrossDissolve],
                animations: {
                    UIView.performWithoutAnimation {
                        // Disabled animations of individual properties.
                        self.configure(viewModel: viewModel)
                    }
                }
            )
        } else {
            UIView.performWithoutAnimation {
                configure(viewModel: viewModel)
            }
        }
    }

    weak var delegate: InputFormViewDelegate?

    /// Current text field.
    private(set) var textField: TextFieldType?

    // MARK: - Constants

    private enum Constants {
        static let animationDuration: TimeInterval = 0.25
    }

    // MARK: - Private Properties

    private let style: POInputFormStyle

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = false
        label.numberOfLines = 0
        label.contentMode = .top
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = false
        label.numberOfLines = 0
        label.contentMode = .top
        return label
    }()

    private lazy var inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var contentView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, inputContainerView, descriptionLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = 8
        return view
    }()

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        let constraints = [
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            inputContainerView.heightAnchor.constraint(equalToConstant: 48)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func configure(viewModel: ViewModel) {
        let style = viewModel.isInError ? style.error : style.normal
        titleLabel.attributedText = AttributedStringBuilder()
            .typography(style.title.typography)
            .textColor(style.title.color)
            .alignment(.center)
            .string(viewModel.title)
            .build()
        if let length = viewModel.length {
            configureCodeTextField(length: length, style: style.field)
        } else {
            configureNormalTextField(placeholder: viewModel.placeholder, style: style.field)
        }
        if let description = viewModel.description, !description.isEmpty {
            descriptionLabel.attributedText = AttributedStringBuilder()
                .typography(style.description.typography)
                .textColor(style.description.color)
                .alignment(.center)
                .string(description)
                .build()
            descriptionLabel.isHidden = false
            descriptionLabel.alpha = 1
        } else {
            descriptionLabel.isHidden = true
            descriptionLabel.alpha = 0
        }
    }

    private func configureCodeTextField(length: Int, style: POTextFieldStyle) {
        if let textField = textField as? CodeTextField {
            textField.length = length
            textField.style = style
        } else {
            let textField = CodeTextField(length: length, style: style)
            textField.delegate = self
            replaceCurrentTextField(with: textField)
        }
    }

    private func configureNormalTextField(placeholder: String?, style: POTextFieldStyle) {
        if let textField = textField as? TextField {
            textField.style = style
            textField.placeholder = placeholder
        } else {
            let textField = TextField(style: style)
            textField.delegate = self
            replaceCurrentTextField(with: textField)
        }
    }

    private func replaceCurrentTextField(with replacementTextField: TextFieldType) {
        replacementTextField.text = textField?.text
        inputContainerView.addSubview(replacementTextField)
        let constraints = [
            replacementTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor),
            replacementTextField.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor),
            replacementTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor),
            replacementTextField.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        textField?.removeFromSuperview()
        textField = replacementTextField
    }
}

extension InputFormView: CodeTextFieldDelegate {

    func codeTextFieldShouldBeginEditing(_ textField: CodeTextField) -> Bool {
        delegate?.inputFormTextFieldShouldBeginEditing(textField) ?? true
    }

    func codeTextField(
        _ textField: CodeTextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        delegate?.inputFormTextField(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }

    func codeTextFieldShouldReturn(_ textField: CodeTextField) -> Bool {
        delegate?.inputFormTextFieldShouldReturn(textField) ?? true
    }
}

extension InputFormView: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.inputFormTextFieldShouldBeginEditing(textField) ?? true
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        delegate?.inputFormTextField(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.inputFormTextFieldShouldReturn(textField) ?? true
    }
}

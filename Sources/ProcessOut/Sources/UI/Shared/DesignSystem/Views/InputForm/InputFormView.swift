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

        /// Boolean flag indicating whether input is currently in error state.
        let isInError: Bool
    }

    // MARK: -

    init(textField: InputFormTextFieldType, style: POInputFormStyle) {
        self.textField = textField
        self.style = style
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: ViewModel, animated: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) { [self] in
            CATransaction.begin()
            CATransaction.setDisableActions(!animated)
            let style = viewModel.isInError ? style.error : style.normal
            if let description = viewModel.description, !description.isEmpty {
                descriptionLabel.attributedText = AttributedStringBuilder()
                    .typography(style.description.typography)
                    .textStyle(textStyle: .footnote)
                    .textColor(style.description.color)
                    .alignment(.center)
                    .string(description)
                    .build()
                descriptionLabel.addTransitionAnimation()
                descriptionLabel.alpha = 1
                textFieldBottomConstraint.isActive = false
                descriptionLabelBottomConstraint.isActive = true
            } else {
                descriptionLabel.alpha = 0
                descriptionLabelBottomConstraint.isActive = false
                textFieldBottomConstraint.isActive = true
            }
            titleLabel.attributedText = AttributedStringBuilder()
                .typography(style.title.typography)
                .textStyle(textStyle: .body)
                .textColor(style.title.color)
                .alignment(.center)
                .string(viewModel.title)
                .build()
            textField.configure(style: style.field, animated: animated)
            CATransaction.commit()
        }
    }

    let textField: InputFormTextFieldType

    // MARK: - Constants

    private enum Constants {
        static let animationDuration: TimeInterval = 0.25
        static let verticalSpacing: CGFloat = 8
    }

    // MARK: - Private Properties

    private let style: POInputFormStyle

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = false
        label.numberOfLines = 0
        label.contentMode = .top
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private lazy var textFieldBottomConstraint = textField.bottomAnchor.constraint(equalTo: bottomAnchor)
    private lazy var descriptionLabelBottomConstraint = descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(descriptionLabel)
        let constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.centerXAnchor.constraint(equalTo: centerXAnchor),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.verticalSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: Constants.verticalSpacing),
            descriptionLabelBottomConstraint
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

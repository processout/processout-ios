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
            titleLabel.attributedText = AttributedStringBuilder()
                .typography(style.title.typography)
                .textColor(style.title.color)
                .alignment(.center)
                .string(viewModel.title)
                .build()
            textField.configure(style: style.field, animated: animated)
            if let description = viewModel.description, !description.isEmpty {
                descriptionLabel.attributedText = AttributedStringBuilder()
                    .typography(style.description.typography)
                    .textColor(style.description.color)
                    .alignment(.center)
                    .string(description)
                    .build()
                descriptionLabel.alpha = 1
                descriptionLabel.setHidden(false)
            } else {
                descriptionLabel.alpha = 0
                descriptionLabel.setHidden(true)
            }
            contentView.setNeedsLayout()
            contentView.layoutIfNeeded()
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
        label.contentMode = .top
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

    private lazy var contentView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, textField, descriptionLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = Constants.verticalSpacing
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
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

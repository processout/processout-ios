//
//  TextFieldContainerView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.11.2022.
//

import UIKit

final class TextFieldContainerView: UIView {

    init() {
        isInvalid = false
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let style, traitCollection.isColorAppearanceDifferent(to: previousTraitCollection) {
            let stateStyle = isInvalid ? style.error : style.normal
            layer.borderColor = stateStyle.border.color.cgColor
            layer.shadowColor = stateStyle.shadow.color.cgColor
        }
    }

    // MARK: - TextFieldContainerView

    private(set) var isInvalid: Bool

    private(set) lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.adjustsFontForContentSizeCategory = false
        return textField
    }()

    func configure(isInvalid: Bool, style: POInputStyle, animated: Bool) {
        self.style = style
        self.isInvalid = isInvalid
        configureWithCurrentState(animated: animated)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let animationDuration: TimeInterval = 0.35
        static let maximumFontSize: CGFloat = 22
        static let height: CGFloat = 44
        static let horizontalInset: CGFloat = 12
    }

    // MARK: - Private Properties

    private var style: POInputStyle?
    private var placeholderObservation: NSKeyValueObservation?

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        let constraints = [
            heightAnchor.constraint(equalToConstant: Constants.height),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalInset),
            textField.centerXAnchor.constraint(equalTo: centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        placeholderObservation = textField.observe(\.placeholder, options: .old) { [weak self] textField, value in
            if textField.placeholder != value.oldValue {
                self?.configureWithCurrentState(animated: false)
            }
        }
    }

    private func configureWithCurrentState(animated: Bool) {
        guard let style else {
            return
        }
        let stateStyle = isInvalid ? style.error : style.normal
        UIView.perform(withAnimation: animated, duration: Constants.animationDuration) { [self] in
            let excludedTextAttributes: Set<NSAttributedString.Key> = [.paragraphStyle, .baselineOffset]
            let textAttributes = AttributedStringBuilder()
                .with { builder in
                    builder.typography = stateStyle.text.typography
                    builder.textStyle = .body
                    builder.maximumFontSize = Constants.maximumFontSize
                    builder.color = stateStyle.text.color
                }
                .buildAttributes()
                .filter { !excludedTextAttributes.contains($0.key) }
            textField.defaultTextAttributes = textAttributes
            // `defaultTextAttributes` overwrites placeholder attributes so `attributedPlaceholder` must be set after.
            textField.attributedPlaceholder = AttributedStringBuilder()
                .with { builder in
                    builder.typography = stateStyle.placeholder.typography
                    builder.textStyle = .body
                    builder.maximumFontSize = Constants.maximumFontSize
                    builder.color = stateStyle.placeholder.color
                    builder.text = .plain(textField.placeholder ?? "")
                }
                .build()
            apply(style: stateStyle.border)
            apply(style: stateStyle.shadow)
            tintColor = stateStyle.tintColor
            backgroundColor = stateStyle.backgroundColor
            UIView.performWithoutAnimation(layoutIfNeeded)
        }
    }
}

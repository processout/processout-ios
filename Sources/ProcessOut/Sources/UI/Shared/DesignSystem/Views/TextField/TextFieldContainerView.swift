//
//  TextFieldContainerView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.11.2022.
//

import UIKit

final class TextFieldContainerView: UIView, InputFormTextField {

    init() {
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
            layer.borderColor = style.border.color.cgColor
            layer.shadowColor = style.shadow.color.cgColor
        }
    }

    func configure(style: POTextFieldStyle, animated: Bool) {
        self.style = style
        configureWithCurrentState(animated: animated)
    }

    var control: UIControl {
        textField
    }

    private(set) lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.adjustsFontForContentSizeCategory = false
        return textField
    }()

    // MARK: - Private Nested Types

    private enum Constants {
        static let animationDuration: TimeInterval = 0.35
        static let maximumFontSize: CGFloat = 30
        static let height: CGFloat = 48
        static let horizontalInset: CGFloat = 12
    }

    // MARK: - Private Properties

    private var style: POTextFieldStyle?
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
        UIView.perform(withAnimation: animated, duration: Constants.animationDuration) { [self] in
            let excludedTextAttributes: Set<NSAttributedString.Key> = [.paragraphStyle, .baselineOffset]
            let textAttributes = AttributedStringBuilder()
                .typography(style.text.typography)
                .textStyle(textStyle: .body)
                .maximumFontSize(Constants.maximumFontSize)
                .textColor(style.text.color)
                .buildAttributes()
                .filter { !excludedTextAttributes.contains($0.key) }
            textField.defaultTextAttributes = textAttributes
            // `defaultTextAttributes` overwrites placeholder attributes so `attributedPlaceholder` must be set after.
            textField.attributedPlaceholder = AttributedStringBuilder()
                .typography(style.placeholder.typography)
                .textStyle(textStyle: .body)
                .maximumFontSize(Constants.maximumFontSize)
                .textColor(style.placeholder.color)
                .string(textField.placeholder ?? "")
                .build()
            apply(style: style.border)
            apply(style: style.shadow)
            tintColor = style.tintColor
            backgroundColor = style.backgroundColor
            UIView.performWithoutAnimation(layoutIfNeeded)
        }
    }
}

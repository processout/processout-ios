//
//  TextField.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.11.2022.
//

import UIKit

final class TextFieldContainerView: UIView, InputFormTextFieldType {

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        return textField
    }()

    // MARK: - Private Nested Types

    private enum Constants {
        static let animationDuration: TimeInterval = 0.35
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
        placeholderObservation = textField.observe(\.placeholder) { [weak self] _, _ in
            self?.configureWithCurrentState(animated: false)
        }
        configureWithCurrentState(animated: false)
    }

    private func configureWithCurrentState(animated: Bool) {
        guard let style else {
            return
        }
        UIView.performWithoutAnimation {
            textField.attributedPlaceholder = AttributedStringBuilder()
                .typography(style.placeholder.typography)
                .textColor(style.placeholder.color)
                .string(textField.placeholder ?? "")
                .build()
            let excludedTextAttributes: Set<NSAttributedString.Key> = [.paragraphStyle, .baselineOffset]
            let textAttributes = AttributedStringBuilder()
                .typography(style.text.typography)
                .textColor(style.text.color)
                .buildAttributes()
                .filter { !excludedTextAttributes.contains($0.key) }
            textField.defaultTextAttributes = textAttributes
        }
        UIView.animate(withDuration: Constants.animationDuration) { [self] in
            CATransaction.begin()
            CATransaction.setDisableActions(!animated)
            apply(style: style.border)
            apply(style: style.shadow)
            tintColor = style.tintColor
            backgroundColor = style.backgroundColor
            CATransaction.commit()
        }
    }
}

//
//  TextField.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.11.2022.
//

import UIKit

final class TextField: UITextField {

    init(style: POTextFieldStyle) {
        self.style = style
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var style: POTextFieldStyle {
        didSet { configure() }
    }

    override var placeholder: String? {
        didSet { configure() }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: Constants.horizontalInset, dy: 0)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: Constants.horizontalInset, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: Constants.horizontalInset, dy: 0)
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: super.intrinsicContentSize.width, height: Constants.height)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let height: CGFloat = 48
        static let horizontalInset: CGFloat = 12
    }

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        configure()
    }

    private func configure() {
        let excludedTextAttributes: Set<NSAttributedString.Key> = [.paragraphStyle, .baselineOffset]
        let textAttributes = AttributedStringBuilder()
            .typography(style.text.typography)
            .textColor(style.text.color)
            .buildAttributes()
            .filter { !excludedTextAttributes.contains($0.key) }
        defaultTextAttributes = textAttributes
        typingAttributes = textAttributes
        attributedPlaceholder = AttributedStringBuilder()
            .typography(style.placeholder.typography)
            .textColor(style.placeholder.color)
            .string(placeholder ?? "")
            .build()
        backgroundColor = style.backgroundColor
        apply(style: style.border)
        apply(style: style.shadow)
        tintColor = style.tintColor
    }
}

//
//  RadioButton.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 06.06.2023.
//

import Foundation
import UIKit

// todo(andrii-vysotskyi): respond to `isSelected` changes.
final class RadioButton: UIControl {

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet { configureWithCurrentState(animated: true) }
    }

    func configure(viewModel: RadioButtonViewModel, style: PORadioButtonStyle, animated: Bool) {
        self.viewModel = viewModel
        self.style = style
        configureWithCurrentState(animated: animated)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let minimumHeight: CGFloat = 40
        static let knobSize: CGFloat = 18
        static let animationDuration: TimeInterval = 0.25
        static let horizontalSpacing: CGFloat = 8
    }

    // MARK: - Private Properties

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.adjustsFontForContentSizeCategory = false
        return label
    }()

    private lazy var knobView = RadioButtonKnobView(size: Constants.knobSize)
    private lazy var knobViewCenterYConstraint = knobView.centerYAnchor.constraint(equalTo: valueLabel.topAnchor)

    private var viewModel: RadioButtonViewModel?
    private var style: PORadioButtonStyle?

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(knobView)
        addSubview(valueLabel)
        let constraints = [
            heightAnchor.constraint(equalToConstant: Constants.minimumHeight).with(priority: .defaultHigh),
            knobView.leadingAnchor.constraint(equalTo: leadingAnchor),
            knobViewCenterYConstraint,
            valueLabel.leadingAnchor.constraint(
                equalTo: knobView.trailingAnchor, constant: Constants.horizontalSpacing
            ),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        isAccessibilityElement = true
    }

    private func configureWithCurrentState(animated: Bool) {
        guard let viewModel, let style else {
            return
        }
        let currentStyle = currentStyle(style: style, viewModel: viewModel, isHighlighted: isHighlighted)
        let previousAttributedText = valueLabel.attributedText
        valueLabel.attributedText = AttributedStringBuilder()
            .typography(currentStyle.value.typography)
            .textStyle(textStyle: .body)
            .textColor(currentStyle.value.color)
            .alignment(.natural)
            .string(viewModel.value)
            .build()
        UIView.perform(withAnimation: animated, duration: Constants.animationDuration) { [self] in
            if animated, valueLabel.attributedText != previousAttributedText {
                valueLabel.addTransitionAnimation()
            }
            knobView.configure(style: currentStyle.knob, animated: animated)
            if let text = valueLabel.attributedText,
               let paragraphStyle = text.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
                // Ensures that knob and label's first line are verticaly aligned.
                knobViewCenterYConstraint.constant = paragraphStyle.maximumLineHeight / 2
            } else {
                knobViewCenterYConstraint.constant = 0
                assertionFailure("Paragraph style should be set.")
            }
        }
        if viewModel.isSelected {
            accessibilityTraits = [.button, .selected]
        } else {
            accessibilityTraits = [.button]
        }
        accessibilityLabel = viewModel.value
    }

    private func currentStyle(
        style: PORadioButtonStyle, viewModel: RadioButtonViewModel, isHighlighted: Bool
    ) -> PORadioButtonStateStyle {
        if viewModel.isSelected {
            return style.selected
        }
        if isHighlighted {
            return style.highlighted
        }
        if viewModel.isInError {
            return style.error
        }
        return style.normal
    }
}

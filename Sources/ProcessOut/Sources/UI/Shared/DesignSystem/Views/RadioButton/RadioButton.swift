//
//  RadioButton.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 06.06.2023.
//

import Foundation
import UIKit

final class RadioButton: UIControl {

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: RadioButtonViewModel, style: PORadioButtonStyle = .default, animated: Bool) {
        let currentStyle: PORadioButtonStateStyle
        if viewModel.isInError {
            currentStyle = style.error
        } else if viewModel.isSelected {
            currentStyle = style.selected
        } else {
            currentStyle = style.normal
        }
        let previousAttributedText = valueLabel.attributedText
        valueLabel.attributedText = AttributedStringBuilder()
            .typography(currentStyle.value.typography)
            .textStyle(textStyle: .body)
            .textColor(currentStyle.value.color)
            .alignment(.natural)
            .string(viewModel.value)
            .build()
        UIView.perform(withAnimation: animated, duration: Constants.animationDuration) { [self] in
            // todo(andrii-vysotskyi): center icon view vertically in first line of icon view
            if animated, valueLabel.attributedText != previousAttributedText {
                valueLabel.addTransitionAnimation()
            }
            iconView.configure(isSelected: viewModel.isSelected, color: currentStyle.tintColor, animated: animated)
        }
        self.isSelected = viewModel.isSelected
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let iconSize: CGFloat = 18
        static let animationDuration: CGFloat = 8
        static let horizontalSpacing: CGFloat = 8
    }

    // MARK: - Private Properties

    private lazy var iconView = RadioButtonIconView(size: Constants.iconSize)
    private lazy var iconViewTopConstraint = iconView.topAnchor.constraint(equalTo: topAnchor)

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.adjustsFontForContentSizeCategory = false
        return label
    }()

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)
        addSubview(valueLabel)
        let constraints = [
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconViewTopConstraint,
            iconView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            valueLabel.leadingAnchor.constraint(
                equalTo: iconView.trailingAnchor, constant: Constants.horizontalSpacing
            ),
            valueLabel.topAnchor.constraint(equalTo: topAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor).with(priority: .defaultHigh)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

private final class RadioButtonIconView: UIView {

    init(size: CGFloat) {
        assert(size >= Constants.minimumSize, "Size should be greater than \(Constants.minimumSize)")
        self.size = size
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.isColorAppearanceDifferent(to: previousTraitCollection) {
            innerBorderView.layer.borderColor = color?.cgColor
        }
    }

    func configure(isSelected: Bool, color: UIColor, animated: Bool) {
        UIView.perform(withAnimation: animated, duration: Constants.animationDuration) { [self] in
            if isSelected {
                circleView.alpha = 1
            } else {
                circleView.alpha = 0
            }
            circleView.backgroundColor = color
            innerBorderView.layer.borderColor = color.cgColor
        }
        self.color = color
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let animationDuration: TimeInterval = 0.25
        static let minimumSize = circleSize + innerRingWidth * 2
        static let circleSize: CGFloat = 8
        static let innerRingWidth: CGFloat = 1
    }

    // MARK: - Private Properties

    private let size: CGFloat

    private lazy var circleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.circleSize / 2
        return view
    }()

    private lazy var innerBorderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.borderWidth = Constants.innerRingWidth
        view.layer.cornerRadius = size / 2 - Constants.innerRingWidth
        return view
    }()

    private var color: UIColor?

    // MARK: - Private Methods

    private func commonInit() {
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(innerBorderView)
        addSubview(circleView)
        let constraints = [
            circleView.widthAnchor.constraint(equalToConstant: Constants.circleSize),
            circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor),
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            innerBorderView.widthAnchor.constraint(equalToConstant: size - Constants.innerRingWidth * 2),
            innerBorderView.heightAnchor.constraint(equalTo: innerBorderView.widthAnchor),
            innerBorderView.centerXAnchor.constraint(equalTo: centerXAnchor),
            innerBorderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalTo: widthAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

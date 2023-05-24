//
//  CodeTextFieldComponentView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.11.2022.
//

import UIKit

final class CodeTextFieldComponentView: UIView {

    struct ViewModel {

        /// Components value.
        let value: Character?

        /// Carret position if any.
        let carretPosition: CodeTextFieldCarretPosition?

        /// Style.
        let style: POInputStateStyle
    }

    init(size: CGSize, didSelect: @escaping (CodeTextFieldCarretPosition) -> Void) {
        self.size = size
        self.didSelect = didSelect
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let currentViewModel, traitCollection.isColorAppearanceDifferent(to: previousTraitCollection) {
            layer.borderColor = currentViewModel.style.border.color.cgColor
            layer.shadowColor = currentViewModel.style.shadow.color.cgColor
        }
    }

    func configure(viewModel: ViewModel, animated: Bool) {
        UIView.perform(withAnimation: animated, duration: Constants.animationDuration) { [self] in
            switch viewModel.carretPosition {
            case .none:
                carretView.setHidden(true)
                removeCarretAnimation()
            case .before:
                animateCarretBlinking()
                carretView.setHidden(false)
                carretCenterConstraint.constant = -Constants.carretOffset
            case .after:
                animateCarretBlinking()
                carretView.setHidden(false)
                carretCenterConstraint.constant = Constants.carretOffset
            }
            let previousAttributedText = valueLabel.attributedText
            valueLabel.attributedText = AttributedStringBuilder()
                .typography(viewModel.style.text.typography)
                .textStyle(textStyle: .largeTitle)
                .maximumFontSize(Constants.maximumFontSize)
                .alignment(.center)
                .textColor(viewModel.style.text.color)
                .string(viewModel.value.map(String.init) ?? "")
                .build()
            if animated, valueLabel.attributedText != previousAttributedText {
                valueLabel.addTransitionAnimation()
            }
            apply(style: viewModel.style.border)
            apply(style: viewModel.style.shadow)
            backgroundColor = viewModel.style.backgroundColor
            carretView.backgroundColor = viewModel.style.tintColor
            UIView.performWithoutAnimation(layoutIfNeeded)
        }
        currentViewModel = viewModel
        accessibilityValue = viewModel.value.map(String.init)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let maximumFontSize: CGFloat = 28
        static let carretSize = CGSize(width: 2, height: 24)
        static let carretOffset: CGFloat = 10
        static let animationDuration: TimeInterval = 0.25
        static let carretAnimationDuration: TimeInterval = 0.4
        static let carretAnimationKey = "BlinkingAnimation"
    }

    // MARK: - Private Properties

    private let didSelect: (CodeTextFieldCarretPosition) -> Void
    private let size: CGSize

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = false
        label.isUserInteractionEnabled = false
        return label
    }()

    private lazy var carretView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.alpha = 1
        return view
    }()

    private lazy var carretCenterConstraint: NSLayoutConstraint = {
        carretView.centerXAnchor.constraint(equalTo: centerXAnchor)
    }()

    private var currentViewModel: ViewModel?

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueLabel)
        addSubview(carretView)
        let constraints = [
            heightAnchor.constraint(equalToConstant: size.height),
            widthAnchor.constraint(equalToConstant: size.width),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            carretView.widthAnchor.constraint(equalToConstant: Constants.carretSize.width),
            carretView.heightAnchor.constraint(equalToConstant: Constants.carretSize.height),
            carretView.centerYAnchor.constraint(equalTo: centerYAnchor),
            carretCenterConstraint
        ]
        NSLayoutConstraint.activate(constraints)
        configureGestures()
    }

    private func configureGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didRecognizeTapGesture))
        addGestureRecognizer(tapGesture)
    }

    private func animateCarretBlinking() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = Constants.carretAnimationDuration
        animation.autoreverses = true
        animation.repeatCount = .greatestFiniteMagnitude
        carretView.layer.add(animation, forKey: Constants.carretAnimationKey)
    }

    private func removeCarretAnimation() {
        carretView.layer.removeAnimation(forKey: Constants.carretAnimationKey)
    }

    // MARK: - Actions

    @objc
    private func didRecognizeTapGesture(gesture: UITapGestureRecognizer) {
        let desiredCarretPosition: CodeTextFieldCarretPosition
        if currentViewModel?.value != nil, gesture.location(in: self).x > bounds.midX {
            desiredCarretPosition = .after
        } else {
            desiredCarretPosition = .before
        }
        didSelect(desiredCarretPosition)
    }
}

//
//  CodeTextFieldComponentView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.11.2022.
//

import UIKit

final class CodeTextFieldComponentView: UIView {

    init(style: POTextFieldStyle, didSelect: @escaping (CodeTextFieldCarretPosition) -> Void) {
        self.style = style
        self.didSelect = didSelect
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var value: Character? {
        didSet { configureWithCurrentState() }
    }

    var carretPosition: CodeTextFieldCarretPosition? {
        didSet { configureWithCurrentState() }
    }

    var style: POTextFieldStyle {
        didSet { configureWithCurrentState() }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let size = CGSize(width: 48, height: 48)
        static let minimumWidth: CGFloat = 42
        static let carretSize = CGSize(width: 2, height: 28)
        static let carretOffset: CGFloat = 11
        static let carretAnimationDuration: TimeInterval = 0.4
    }

    // MARK: - Private Properties

    private let didSelect: (CodeTextFieldCarretPosition) -> Void

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
        return view
    }()

    private lazy var carretCenterConstraint: NSLayoutConstraint = {
        carretView.centerXAnchor.constraint(equalTo: centerXAnchor)
    }()

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = widthAnchor.constraint(equalToConstant: Constants.size.width)
        widthConstraint.priority = .defaultHigh
        let constraints = [
            heightAnchor.constraint(equalToConstant: Constants.size.height),
            widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumWidth),
            widthConstraint
        ]
        NSLayoutConstraint.activate(constraints)
        clipsToBounds = true
        addValueLabelSubview()
        addCarretSubview()
        configureGestures()
        configureWithCurrentState()
    }

    private func addValueLabelSubview() {
        addSubview(valueLabel)
        let constraints = [
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func addCarretSubview() {
        UIView.animate(
            withDuration: Constants.carretAnimationDuration,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: {
                self.carretView.alpha = 0
            },
            completion: nil
        )
        addSubview(carretView)
        let constraints = [
            carretView.widthAnchor.constraint(equalToConstant: Constants.carretSize.width),
            carretView.heightAnchor.constraint(equalToConstant: Constants.carretSize.height),
            carretView.centerYAnchor.constraint(equalTo: centerYAnchor),
            carretCenterConstraint
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func configureGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didRecognizeTapGesture))
        addGestureRecognizer(tapGesture)
    }

    private func configureWithCurrentState() {
        valueLabel.attributedText = AttributedStringBuilder()
            .typography(style.text.typography)
            .textColor(style.text.color)
            .string(value.map(String.init) ?? "")
            .build()
        switch carretPosition {
        case .none:
            carretView.isHidden = true
        case .before:
            carretView.isHidden = false
            carretCenterConstraint.constant = -Constants.carretOffset
        case .after:
            carretView.isHidden = false
            carretCenterConstraint.constant = Constants.carretOffset
        }
        apply(style: style.border)
        apply(style: style.shadow)
        backgroundColor = style.backgroundColor
        carretView.backgroundColor = style.tintColor
    }

    // MARK: - Actions

    @objc
    private func didRecognizeTapGesture(gesture: UITapGestureRecognizer) {
        let desiredCarretPosition: CodeTextFieldCarretPosition
        if value != nil, gesture.location(in: self).x > bounds.midX {
            desiredCarretPosition = .after
        } else {
            desiredCarretPosition = .before
        }
        didSelect(desiredCarretPosition)
    }
}

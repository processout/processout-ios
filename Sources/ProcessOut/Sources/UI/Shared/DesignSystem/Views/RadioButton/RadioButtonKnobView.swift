//
//  RadioButtonKnobView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.06.2023.
//

import UIKit

final class RadioButtonKnobView: UIView {

    init(size: CGFloat) {
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
        if traitCollection.isColorAppearanceDifferent(to: previousTraitCollection), let style {
            configureInnerBorderViewBorder(style: style.border)
        }
    }

    func configure(style: PORadioButtonKnobStateStyle, animated: Bool) {
        UIView.perform(withAnimation: animated, duration: Constants.animationDuration) { [self] in
            circleView.layer.cornerRadius = style.innerCircleRadius
            circleViewWidthConstraint.constant = style.innerCircleRadius * 2
            backgroundColor = style.backgroundColor
            circleView.backgroundColor = style.innerCircleColor
            configureInnerBorderViewBorder(style: style.border)
            innerBorderViewWidthConstraint.constant = max(size - 2 * style.border.width, 0)
        }
        self.style = style
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let animationDuration: TimeInterval = 0.25
    }

    // MARK: - Private Properties

    private let size: CGFloat

    private lazy var circleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    private lazy var innerBorderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.clear.cgColor
        return view
    }()

    private lazy var innerBorderViewWidthConstraint = innerBorderView.widthAnchor.constraint(equalToConstant: 0)
    private lazy var circleViewWidthConstraint = circleView.widthAnchor.constraint(equalToConstant: 0)

    private var style: PORadioButtonKnobStateStyle?

    // MARK: - Private Methods

    private func commonInit() {
        clipsToBounds = true
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(innerBorderView)
        addSubview(circleView)
        let constraints = [
            circleViewWidthConstraint,
            circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor),
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            innerBorderViewWidthConstraint,
            innerBorderView.heightAnchor.constraint(equalTo: innerBorderView.widthAnchor),
            innerBorderView.centerXAnchor.constraint(equalTo: centerXAnchor),
            innerBorderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalTo: widthAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func configureInnerBorderViewBorder(style: POBorderStyle) {
        innerBorderView.apply(style: style)
        innerBorderView.layer.cornerRadius = size / 2 - style.width
    }
}

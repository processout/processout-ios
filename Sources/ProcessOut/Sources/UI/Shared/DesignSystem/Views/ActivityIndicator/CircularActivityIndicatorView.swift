//
//  CircularActivityIndicatorView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.11.2022.
//

import UIKit

final class CircularActivityIndicatorView: UIView, ActivityIndicatorViewType {

    init(color: UIColor) {
        self.color = color
        hidesWhenStopped = true
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureMaskLayer()
    }

    func setAnimating(_ isAnimating: Bool) {
        if hidesWhenStopped || isAnimating {
            isHidden = !isAnimating
        }
        if isAnimating {
            addRotationAnimation()
        } else {
            removeRotationAnimationAndUpdateModel()
        }
    }

    var hidesWhenStopped: Bool

    // MARK: - Private Nested Types

    private enum Constants {
        static let size: CGFloat = 24
        static let indicatorInset: CGFloat = 3
        static let indicatorWidth: CGFloat = 1
        static let indicatorArcFraction = 0.875 // In range [0, 1]
        static let animationCycleDuration: CGFloat = 1.5
    }

    // MARK: - Private Properties

    private let color: UIColor

    private lazy var maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = Constants.indicatorWidth
        layer.lineCap = .round
        return layer
    }()

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            widthAnchor.constraint(equalToConstant: Constants.size),
            heightAnchor.constraint(equalToConstant: Constants.size)
        ]
        NSLayoutConstraint.activate(constraints)
        layer.mask = maskLayer
        backgroundColor = color
        setAnimating(false)
    }

    private func configureMaskLayer() {
        let path = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: Constants.size / 2 - Constants.indicatorInset,
            startAngle: 0,
            endAngle: 2 * .pi * Constants.indicatorArcFraction,
            clockwise: true
        )
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
    }

    private func addRotationAnimation() {
        removeRotationAnimationAndUpdateModel()
        let keyPath = "transform.rotation.z"
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.toValue = layer.value(forKeyPath: keyPath) as! CGFloat + .pi * 2 // swiftlint:disable:this force_cast
        animation.duration = Constants.animationCycleDuration
        animation.repeatCount = .infinity
        layer.add(animation, forKey: nil)
    }

    private func removeRotationAnimationAndUpdateModel() {
        let keyPath = "transform.rotation.z"
        if let point = layer.presentation()?.value(forKeyPath: keyPath) as? CGFloat {
            layer.setValue(point, forKeyPath: keyPath)
        }
        layer.removeAllAnimations()
    }
}

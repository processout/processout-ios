//
//  BackgroundDecorationView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 01.12.2022.
//

import UIKit

final class BackgroundDecorationView: UIView {

    init(style: POBackgroundDecorationStyle) {
        self.style = style
        isExpanded = false
        isSuccess = false
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let isAnimated = UIView.inheritedAnimationDuration > 0.01
        configure(isExpanded: isExpanded, isSuccess: isSuccess, animated: isAnimated)
    }

    /// Safe vertical area height that is guaranteed to be fully covered by this decoration.
    private(set) var isExpanded: Bool

    /// Boolean value indicating whether decoration used in success scenario.
    private(set) var isSuccess: Bool

    func configure(isExpanded: Bool, isSuccess: Bool, animated: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) { [self] in
            CATransaction.begin()
            CATransaction.setDisableActions(!animated)
            let baseHeight = isExpanded ? bounds.height : Constants.baseHeight
            let spacing: CGFloat = isSuccess ? Constants.successSpacing : Constants.normalSpacing
            animateShapeLayerPath(innerShapeLayer, height: baseHeight, capHeight: Constants.innerCapHeight)
            animateShapeLayerPath(outerShapeLayer, height: baseHeight + spacing, capHeight: Constants.outerCapHeight)
            if !animated {
                innerShapeLayer.removeAllAnimations()
                outerShapeLayer.removeAllAnimations()
            }
            let currentStyle = isSuccess ? style.success : style.normal
            innerShapeLayer.fillColor = currentStyle.primaryColor.cgColor
            outerShapeLayer.fillColor = currentStyle.secondaryColor.cgColor
            CATransaction.commit()
        }
        self.isExpanded = isExpanded
        self.isSuccess = isSuccess
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let baseHeight: CGFloat = 471
        static let innerCapHeight: CGFloat = 59
        static let outerCapHeight: CGFloat = 46
        static let normalSpacing: CGFloat = 83
        static let successSpacing: CGFloat = 113
        static let animationDuration: TimeInterval = 0.3
    }

    // MARK: - Private Properties

    private let style: POBackgroundDecorationStyle

    private lazy var innerShapeLayer = CAShapeLayer()
    private lazy var outerShapeLayer = CAShapeLayer()

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.addSublayer(outerShapeLayer)
        layer.addSublayer(innerShapeLayer)
        backgroundColor = .clear
        configure(isExpanded: isExpanded, isSuccess: isSuccess, animated: false)
    }

    private func createSheetPath(height: CGFloat, capHeight: CGFloat) -> CGPath {
        let adjustedHeight: CGFloat
        let adjustedCapHeight: CGFloat
        if safeAreaInsets.top + height + capHeight > bounds.height - safeAreaInsets.bottom {
            adjustedHeight = bounds.height
            adjustedCapHeight = 0
        } else {
            adjustedHeight = safeAreaInsets.top + height
            adjustedCapHeight = capHeight
        }
        let path = CGMutablePath()
        path.addLines(between: [
            CGPoint(x: bounds.maxX, y: adjustedHeight),
            CGPoint(x: bounds.maxX, y: 0),
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: adjustedHeight)
        ])
        path.addQuadCurve(
            to: CGPoint(x: bounds.maxX, y: adjustedHeight),
            control: CGPoint(x: bounds.midX, y: adjustedHeight + adjustedCapHeight * 2)
        )
        return path
    }

    private func animateShapeLayerPath(_ layer: CAShapeLayer, height: CGFloat, capHeight: CGFloat) {
        let animation = CABasicAnimation(keyPath: "path")
        let newPath = createSheetPath(height: height, capHeight: capHeight)
        animation.fromValue = layer.presentation()?.path ?? layer.path
        animation.toValue = newPath
        if let backgroundAnimation = layer.action(forKey: "backgroundColor") as? CAAnimation {
            animation.timingFunction = backgroundAnimation.timingFunction
            animation.duration = backgroundAnimation.duration
        }
        layer.path = newPath
        layer.add(animation, forKey: "path")
    }
}

//
//  BackgroundDecorationSheetView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.12.2022.
//

import UIKit

final class BackgroundDecorationSheetView: UIView {

    init(capHeight: CGFloat) {
        self.capHeight = capHeight
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var baseHeight: CGFloat? {
        didSet { layer.path = baseHeight.map(createSheetPath) }
    }

    var fillColor: UIColor? {
        didSet { layer.fillColor = fillColor?.cgColor }
    }

    override class var layerClass: AnyClass {
        CAShapeLayer.self
    }

    override var layer: CAShapeLayer {
        super.layer as! CAShapeLayer // swiftlint:disable:this force_cast
    }

    override func action(for layer: CALayer, forKey event: String) -> CAAction? {
        switch event {
        case "path", "fillColor": // Fill color is not animated on iOS < 16
            let backgroundAnimation = layer.action(forKey: "backgroundColor") as? CAPropertyAnimation
            let animation = backgroundAnimation?.copy() as? CAPropertyAnimation
            animation?.keyPath = event
            return animation
        default:
            return super.action(for: layer, forKey: event)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.isColorAppearanceDifferent(to: previousTraitCollection) {
            layer.fillColor = fillColor?.cgColor
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.path = baseHeight.map(createSheetPath)
    }

    // MARK: - Private Properties

    private let capHeight: CGFloat

    // MARK: - Private Methods

    private func createSheetPath(height: CGFloat) -> CGPath {
        let adjustedHeight: CGFloat
        let adjustedCapHeight: CGFloat
        if safeAreaInsets.top + height + capHeight > bounds.height {
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
}

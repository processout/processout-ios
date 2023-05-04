//
//  BackgroundDecorationView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 01.12.2022.
//

import UIKit

final class BackgroundDecorationView: UIView {

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(isSuccess: Bool, style: POBackgroundDecorationStyle) {
        let currentStyle = isSuccess ? style.success : style.normal
        switch currentStyle {
        case .hidden:
            innerShapeView.fillColor = .clear
            outerShapeView.fillColor = .clear
        case let .visible(primaryColor, secondaryColor):
            innerShapeView.fillColor = primaryColor
            outerShapeView.fillColor = secondaryColor
        }
        innerShapeViewBottomConstraint.constant = -(isSuccess ? Constants.successSpacing : Constants.normalSpacing)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let innerCapHeight: CGFloat = 59
        static let outerCapHeight: CGFloat = 46
        static let normalSpacing: CGFloat = 83
        static let successSpacing: CGFloat = 113
        static let animationDuration: TimeInterval = 0.3
    }

    // MARK: - Private Properties

    private lazy var innerShapeView = BackgroundDecorationSheetView(capHeight: Constants.innerCapHeight)
    private lazy var outerShapeView = BackgroundDecorationSheetView(capHeight: Constants.outerCapHeight)
    private lazy var innerShapeViewBottomConstraint = innerShapeView.bottomAnchor.constraint(equalTo: bottomAnchor)

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(outerShapeView)
        addSubview(innerShapeView)
        let constraints = [
            innerShapeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            innerShapeView.trailingAnchor.constraint(equalTo: trailingAnchor),
            innerShapeView.topAnchor.constraint(equalTo: topAnchor),
            innerShapeViewBottomConstraint,
            outerShapeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            outerShapeView.trailingAnchor.constraint(equalTo: trailingAnchor),
            outerShapeView.topAnchor.constraint(equalTo: topAnchor),
            outerShapeView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        backgroundColor = .clear
    }
}

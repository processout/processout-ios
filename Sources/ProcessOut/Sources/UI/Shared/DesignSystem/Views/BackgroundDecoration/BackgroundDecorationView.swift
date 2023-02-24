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
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(isExpanded: Bool, isSuccess: Bool, animated: Bool) {
        UIView.perform(withAnimation: animated, duration: Constants.animationDuration) { [self] in
            let baseHeight = isExpanded ? bounds.height : Constants.baseHeight
            let spacing: CGFloat = isSuccess ? Constants.successSpacing : Constants.normalSpacing
            innerShapeView.baseHeight = baseHeight
            outerShapeView.baseHeight = baseHeight + spacing
            let currentStyle = isSuccess ? style.success : style.normal
            switch currentStyle {
            case .hidden:
                innerShapeView.fillColor = .clear
                outerShapeView.fillColor = .clear
            case let .visible(primaryColor, secondaryColor):
                innerShapeView.fillColor = primaryColor
                outerShapeView.fillColor = secondaryColor
            }
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let baseHeight: CGFloat = 415
        static let innerCapHeight: CGFloat = 59
        static let outerCapHeight: CGFloat = 46
        static let normalSpacing: CGFloat = 83
        static let successSpacing: CGFloat = 113
        static let animationDuration: TimeInterval = 0.3
    }

    // MARK: - Private Properties

    private let style: POBackgroundDecorationStyle

    private lazy var innerShapeView = BackgroundDecorationSheetView(capHeight: Constants.innerCapHeight)
    private lazy var outerShapeView = BackgroundDecorationSheetView(capHeight: Constants.outerCapHeight)

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(outerShapeView)
        addSubview(innerShapeView)
        let constraints = [
            innerShapeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            innerShapeView.trailingAnchor.constraint(equalTo: trailingAnchor),
            innerShapeView.topAnchor.constraint(equalTo: topAnchor),
            innerShapeView.bottomAnchor.constraint(equalTo: bottomAnchor),
            outerShapeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            outerShapeView.trailingAnchor.constraint(equalTo: trailingAnchor),
            outerShapeView.topAnchor.constraint(equalTo: topAnchor),
            outerShapeView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        backgroundColor = .clear
    }
}

//
//  NativeAlternativePaymentMethodSectionDecorationView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.05.2023.
//

import UIKit

// swiftlint:disable:next type_name
final class NativeAlternativePaymentMethodSectionDecorationView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        item: NativeAlternativePaymentMethodViewModelState.SectionDecoration, style: POBackgroundDecorationStyle?
    ) {
        decorationView.configure(isSuccess: item == .success, style: style ?? Constants.defaultStyle)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let defaultStyle = POBackgroundDecorationStyle.default
    }

    // MARK: - Private Properties

    private lazy var decorationView = BackgroundDecorationView()

    // MARK: - Private Methods

    private func commonInit() {
        addSubview(decorationView)
        let constraints = [
            decorationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            decorationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            decorationView.topAnchor.constraint(equalTo: topAnchor),
            decorationView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

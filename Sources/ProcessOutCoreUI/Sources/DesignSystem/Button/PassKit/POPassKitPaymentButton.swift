//
//  POPassKitPaymentButton.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 18.04.2024.
//

import SwiftUI
import PassKit

@available(iOS 14.0, *)
@_spi(PO)
public struct POPassKitPaymentButton: View {

    public init(
        type: PKPaymentButtonType = .plain,
        style: PKPaymentButtonStyle = .automatic,
        action: @escaping () -> Void
    ) {
        self.buttonType = type
        self.style = style
        self.action = action
    }

    // MARK: - View

    public var body: some View {
        ButtonRepresentable(buttonType: buttonType, style: style, action: action)
            .id(buttonType)
            .id(style)
            .frame(height: Constants.minHeight)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let minHeight: CGFloat = 44
    }

    // MARK: - Private Properties

    private let buttonType: PKPaymentButtonType
    private let style: PKPaymentButtonStyle
    private let action: () -> Void
}

@available(iOS 14.0, *)
private struct ButtonRepresentable: UIViewRepresentable {

    let buttonType: PKPaymentButtonType
    let style: PKPaymentButtonStyle
    let action: () -> Void

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: buttonType, paymentButtonStyle: style)
        context.coordinator.observeActions(control: button)
        return button
    }

    func updateUIView(_ rootView: PKPaymentButton, context: Context) {
        // todo(andrii-vysotskyi): allow configuring corner radius
        rootView.cornerRadius = 8
        context.coordinator.action = action
    }

    func makeCoordinator() -> ButtonCoordinator {
        ButtonCoordinator(action: action)
    }
}

private final class ButtonCoordinator {

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var action: () -> Void

    func observeActions(control: UIControl) {
        control.addTarget(self, action: #selector(callback), for: .touchUpInside)
    }

    // MARK: - Private Properties

    @objc private func callback() {
        action()
    }
}

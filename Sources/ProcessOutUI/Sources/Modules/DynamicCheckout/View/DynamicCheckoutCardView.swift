//
//  DynamicCheckoutCardView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 06.05.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
@MainActor
struct DynamicCheckoutCardView: View {

    init(item: DynamicCheckoutViewModelItem.Card) {
        _viewModel = .init(wrappedValue: item.viewModel())
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: POSpacing.large) {
            CardTokenizationContentView(viewModel: viewModel, insets: 0)
                .cardTokenizationStyle(.init(dynamicCheckoutStyle: style))
            DynamicCheckoutPaymentMethodButtonsView(buttons: viewModel.state.actions)
        }
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style

    @StateObject
    private var viewModel: AnyViewModel<CardTokenizationViewModelState>
}

@available(iOS 14, *)
extension POCardTokenizationStyle {

    // swiftlint:disable:next strict_fileprivate
    fileprivate init(dynamicCheckoutStyle style: PODynamicCheckoutStyle) {
        title = POCardTokenizationStyle.default.title
        sectionTitle = style.inputTitle
        input = style.input
        radioButton = style.radioButton
        toggle = style.toggle
        errorDescription = style.errorText
        backgroundColor = style.backgroundColor
        actionsContainer = style.actionsContainer
        separatorColor = POCardTokenizationStyle.default.separatorColor
    }
}

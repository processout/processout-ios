//
//  POCardUpdateView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// View that allows user to enter card details and tokenize it.
@available(iOS 14, *)
public struct POCardUpdateView: View {

    init(viewModel: some CardUpdateViewModel) {
        self._viewModel = .init(wrappedValue: .init(erasing: viewModel))
    }

    // MARK: - View

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Constants.spacing) {
                    if let title = viewModel.title {
                        Text(title)
                            .textStyle(style.title)
                            .padding(.horizontal, Constants.horizontalPadding)
                        Divider()
                            .frame(height: 1)
                            .overlay(style.separatorColor)
                    }
                    ForEach(viewModel.items) { element in
                        CardUpdateItemView(item: element, focusedInputId: $viewModel.focusedItemId)
                    }
                    .padding(.horizontal, Constants.horizontalPadding)
                    .backport.geometryGroup()
                }
                .padding(.vertical, Constants.spacing)
                .animation(.default, value: viewModel.items.map(\.id))
            }
            .clipped()
            POActionsContainerView(actions: viewModel.actions)
                .actionsContainerStyle(style.actionsContainer)
                .layoutPriority(1)
        }
        .background(style.backgroundColor.ignoresSafeArea())
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let spacing: CGFloat = 16
        static let horizontalPadding: CGFloat = 24
    }

    // MARK: - Private Properties

    @Environment(\.cardUpdateStyle)
    private var style

    @StateObject
    private var viewModel: AnyCardUpdateViewModel
}

//
//  POCardTokenizationView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 24.07.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// View that allows user to enter card details and tokenize it.
@available(iOS 14, *)
public struct POCardTokenizationView: View {

    init(viewModel: some CardTokenizationViewModel) {
        self._viewModel = .init(wrappedValue: .init(erasing: viewModel))
    }

    // MARK: - View

    public var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollView in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: POSpacing.medium) {
                        if let title = viewModel.state.title {
                            Text(title)
                                .textStyle(style.title)
                                .padding(.horizontal, POSpacing.large)
                            Divider()
                                .frame(height: 1)
                                .overlay(style.separatorColor)
                        }
                        ForEach(viewModel.state.sections) { section in
                            CardTokenizationSectionView(
                                section: section, focusedInputId: $viewModel.state.focusedInputId
                            )
                        }
                        .padding(.horizontal, POSpacing.large)
                    }
                    .animation(.default, value: viewModel.state.sections.map(\.id))
                    .animation(.default, value: viewModel.state.sections.flatMap(\.items).map(\.id))
                    .padding(.vertical, POSpacing.medium)
                }
                .backport.onChange(of: viewModel.state.focusedInputId) {
                    scrollToFocusedInput(scrollView: scrollView)
                }
                .clipped()
            }
            POActionsContainerView(actions: viewModel.state.actions)
                .actionsContainerStyle(style.actionsContainer)
        }
        .background(style.backgroundColor.ignoresSafeArea())
    }

    // MARK: - Private Properties

    @Environment(\.cardTokenizationStyle)
    private var style

    @StateObject
    private var viewModel: AnyCardTokenizationViewModel

    // MARK: - Private Methods

    private func scrollToFocusedInput(scrollView: ScrollViewProxy) {
        guard let id = viewModel.state.focusedInputId else {
            return
        }
        withAnimation { scrollView.scrollTo(id) }
    }
}

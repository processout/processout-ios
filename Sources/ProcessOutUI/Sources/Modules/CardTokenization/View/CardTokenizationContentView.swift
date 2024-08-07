//
//  CardTokenizationContentView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 25.04.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14.0, *)
struct CardTokenizationContentView: View {

    init(viewModel: AnyViewModel<CardTokenizationViewModelState>, insets: CGFloat) {
        self.viewModel = viewModel
        self.insets = insets
    }

    // MARK: - View

    var body: some View {
        ScrollViewReader { scrollView in
            VStack(alignment: .leading, spacing: POSpacing.large) {
                if let title = viewModel.state.title {
                    Text(title)
                        .textStyle(style.title)
                        .padding(EdgeInsets(horizontal: insets, vertical: 0))
                    Divider()
                        .frame(height: 1)
                        .overlay(style.separatorColor)
                }
                ForEach(viewModel.state.sections) { section in
                    CardTokenizationSectionView(
                        section: section, focusedInputId: $viewModel.state.focusedInputId
                    )
                }
                .padding(EdgeInsets(horizontal: insets, vertical: 0))
            }
            .backport.onChange(of: viewModel.state.focusedInputId) {
                scrollToFocusedInput(scrollView: scrollView)
            }
            .padding(EdgeInsets(horizontal: 0, vertical: insets))
            .frame(maxWidth: .infinity)
        }
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    private let insets: CGFloat

    @Environment(\.cardTokenizationStyle)
    private var style

    @ObservedObject
    private var viewModel: AnyViewModel<CardTokenizationViewModelState>

    // MARK: - Private Methods

    private func scrollToFocusedInput(scrollView: ScrollViewProxy) {
        guard let id = viewModel.state.focusedInputId else {
            return
        }
        withAnimation { scrollView.scrollTo(id) }
    }
}

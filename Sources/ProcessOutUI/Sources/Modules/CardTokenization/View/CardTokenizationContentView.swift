//
//  CardTokenizationContentView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 25.04.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14.0, *)
struct CardTokenizationContentView<ViewModel: CardTokenizationViewModel>: View {

    init(viewModel: ViewModel, horizontalPadding: CGFloat = POSpacing.large) {
        self.viewModel = viewModel
        self.horizontalPadding = horizontalPadding
    }

    // MARK: - View

    var body: some View {
        ScrollViewReader { scrollView in
            VStack(alignment: .leading, spacing: POSpacing.medium) {
                if let title = viewModel.state.title {
                    Text(title)
                        .textStyle(style.title)
                        .padding(.horizontal, horizontalPadding)
                    Divider()
                        .frame(height: 1)
                        .overlay(style.separatorColor)
                }
                ForEach(viewModel.state.sections) { section in
                    CardTokenizationSectionView(
                        section: section, focusedInputId: $viewModel.state.focusedInputId
                    )
                }
                .padding(.horizontal, horizontalPadding)
            }
            .backport.onChange(of: viewModel.state.focusedInputId) {
                scrollToFocusedInput(scrollView: scrollView)
            }
            .padding(.vertical, POSpacing.medium)
            .frame(maxWidth: .infinity)
        }
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    private let horizontalPadding: CGFloat

    @Environment(\.cardTokenizationStyle)
    private var style

    @ObservedObject
    private var viewModel: ViewModel

    // MARK: - Private Methods

    private func scrollToFocusedInput(scrollView: ScrollViewProxy) {
        guard let id = viewModel.state.focusedInputId else {
            return
        }
        withAnimation { scrollView.scrollTo(id) }
    }
}

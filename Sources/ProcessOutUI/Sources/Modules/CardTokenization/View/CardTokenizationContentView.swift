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

    @ObservedObject
    private(set) var viewModel: ViewModel

    // MARK: - View

    var body: some View {
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
        .backport.onChange(of: viewModel.state.focusedInputId) {
            scrollToFocusedInput()
        }
        .padding(.vertical, POSpacing.medium)
        .frame(maxWidth: .infinity)
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.cardTokenizationStyle)
    private var style

    @Environment(\.scrollViewProxy)
    private var scrollView

    // MARK: - Private Methods

    private func scrollToFocusedInput() {
        guard let id = viewModel.state.focusedInputId else {
            return
        }
        withAnimation { scrollView?.scrollTo(id) }
    }
}

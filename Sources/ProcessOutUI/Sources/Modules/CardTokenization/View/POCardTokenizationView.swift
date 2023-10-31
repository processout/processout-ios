//
//  POCardTokenizationView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 24.07.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
public struct POCardTokenizationView: View {

    init(viewModel: some CardTokenizationViewModel) {
        self._viewModel = .init(wrappedValue: .init(erasing: viewModel))
    }

    // MARK: - View

    public var body: some View {
        // todo(andrii-vysotskyi): handle keyboard on iOS 13
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Constants.spacing) {
                        if let title = viewModel.state.title {
                            Text(title)
                                .textStyle(style.title)
                                .padding(.horizontal, Constants.horizontalPadding)
                            Divider()
                                .frame(height: 1)
                                .overlay(style.separatorColor)
                        }
                        VStack(alignment: .leading, spacing: Constants.spacing) {
                            ForEach(viewModel.state.sections) { section in
                                CardTokenizationSectionView(
                                    section: section,
                                    spacing: Constants.sectionSpacing,
                                    focusedInputId: $viewModel.state.focusedInputId
                                )
                            }
                        }
                        .padding(.horizontal, Constants.horizontalPadding)
                        .frame(maxHeight: .infinity)
                    }
                    .padding(.vertical, Constants.spacing)
                    .frame(minHeight: geometry.size.height)
                    .animation(.default, value: viewModel.state.sections.map(\.id))
                }
                .clipped()
            }
            POActionsContainerView(
                actions: viewModel.state.actions,
                spacing: Constants.spacing,
                horizontalPadding: Constants.horizontalPadding
            )
            .actionsContainerStyle(style.actionsContainer)
        }
        .background(style.backgroundColor.edgesIgnoringSafeArea(.all))
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let spacing: CGFloat = 16
        static let sectionSpacing: CGFloat = 8
        static let horizontalPadding: CGFloat = 24
    }

    // MARK: - Private Properties

    @Environment(\.cardTokenizationStyle)
    private var style

    @StateObject
    private var viewModel: AnyCardTokenizationViewModel
}

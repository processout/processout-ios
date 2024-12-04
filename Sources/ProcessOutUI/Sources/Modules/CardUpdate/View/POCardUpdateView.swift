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
@MainActor
@preconcurrency
public struct POCardUpdateView: View {

    init(viewModel: @autoclosure @escaping () -> some CardUpdateViewModel) {
        self._viewModel = .init(wrappedValue: .init(erasing: viewModel()))
    }

    // MARK: - View

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: POSpacing.large) {
                    if let title = viewModel.title {
                        Text(title)
                            .textStyle(style.title)
                            .padding(.horizontal, POSpacing.large)
                        Rectangle()
                            .fill(style.separatorColor)
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                    }
                    ForEach(viewModel.sections) { element in
                        CardUpdateSectionView(section: element, focusedInputId: $viewModel.focusedItemId)
                    }
                    .padding(.horizontal, POSpacing.large)
                    .backport.geometryGroup()
                }
                .animation(.default, value: bodyAnimationValue)
                .padding(.vertical, POSpacing.large)
            }
            .clipped()
            POActionsContainerView(actions: viewModel.actions)
                .actionsContainerStyle(style.actionsContainer)
        }
        .backport.background {
            style.backgroundColor.ignoresSafeArea()
        }
        .onAppear(perform: viewModel.start)
    }

    // MARK: - Private Properties

    @Environment(\.cardUpdateStyle)
    private var style

    @StateObject
    private var viewModel: AnyCardUpdateViewModel

    // MARK: - Animation

    /// Returns value that should trigger whole body animated update.
    private var bodyAnimationValue: AnyHashable {
        viewModel.sections.map { [$0.id, $0.items.map(\.id)] }
    }
}

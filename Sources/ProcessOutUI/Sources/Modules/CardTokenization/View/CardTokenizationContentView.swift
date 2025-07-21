//
//  CardTokenizationContentView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 25.04.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@MainActor
struct CardTokenizationContentView: View {

    init(viewModel: AnyViewModel<CardTokenizationViewModelState>) {
        self.viewModel = viewModel
    }

    // MARK: - View

    var body: some View {
        ScrollViewReader { scrollView in
            VStack(alignment: .leading, spacing: POSpacing.space20) {
                if let title = viewModel.state.title {
                    Text(title)
                        .textStyle(style.title)
                        .padding(EdgeInsets(horizontal: contentInsets, vertical: 0))
                    Rectangle()
                        .fill(style.separatorColor)
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)
                }
                ForEach(viewModel.state.sections) { section in
                    CardTokenizationSectionView(
                        section: section, focusedInputId: $viewModel.state.focusedInputId
                    )
                }
                .padding(EdgeInsets(horizontal: contentInsets, vertical: 0))
                if let controls = viewModel.state.controls, prefersInlineLayout(controlGroup: controls) {
                    CardTokenizationInlineControlGroupView(configuration: controls)
                        .padding(.horizontal, contentInsets)
                }
            }
            .backport.onChange(of: viewModel.state.focusedInputId) {
                scrollToFocusedInput(scrollView: scrollView)
            }
            .padding(EdgeInsets(horizontal: 0, vertical: contentInsets))
            .frame(maxWidth: .infinity)
        }
        .sheet(item: $viewModel.state.cardScanner) { scanner in
            POCardScannerView(configuration: scanner.configuration, completion: scanner.completion)
                .fittedPresentationDetent()
                .modify { content in
                    if #available(iOS 16.4, *) {
                        content
                            .presentationCornerRadius(24)
                            .presentationBackgroundInteraction(.disabled)
                    } else {
                        content
                    }
                }
                .backport.background {
                    cardScannerStyle.backgroundColor.ignoresSafeArea()
                }
        }
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.cardTokenizationStyle)
    private var style

    @Environment(\.cardTokenizationPresentationContext)
    private var presentationContext

    @Environment(\.cardScannerStyle)
    private var cardScannerStyle

    @ObservedObject
    private var viewModel: AnyViewModel<CardTokenizationViewModelState>

    // MARK: - Private Methods

    private func scrollToFocusedInput(scrollView: ScrollViewProxy) {
        guard let id = viewModel.state.focusedInputId else {
            return
        }
        withAnimation { scrollView.scrollTo(id) }
    }

    private var contentInsets: CGFloat {
        presentationContext == .standalone ? POSpacing.space20 : 0
    }

    private func prefersInlineLayout(controlGroup: CardTokenizationViewModelControlGroup) -> Bool {
        switch presentationContext {
        case .inline:
            return true
        case .standalone:
            return controlGroup.inline
        }
    }
}

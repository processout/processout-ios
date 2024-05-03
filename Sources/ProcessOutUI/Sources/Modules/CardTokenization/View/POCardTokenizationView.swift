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

    init(viewModel: @autoclosure @escaping () -> some CardTokenizationViewModel) {
        self._viewModel = .init(wrappedValue: .init(erasing: viewModel()))
    }

    // MARK: - View

    public var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollView in
                ScrollView(showsIndicators: false) {
                    CardTokenizationContentView(viewModel: viewModel)
                        .scrollViewProxy(scrollView)
                }
                .clipped()
            }
            if !viewModel.state.actions.isEmpty {
                POActionsContainerView(actions: viewModel.state.actions)
                    .actionsContainerStyle(style.actionsContainer)
            }
        }
        .backport.background {
            style.backgroundColor.ignoresSafeArea()
        }
        .onAppear(perform: viewModel.start)
    }

    // MARK: - Private Properties

    @Environment(\.cardTokenizationStyle)
    private var style

    @StateObject
    private var viewModel: AnyCardTokenizationViewModel
}

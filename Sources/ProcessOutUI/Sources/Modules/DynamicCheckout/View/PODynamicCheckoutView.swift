//
//  DynamicCheckoutView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.02.2024.
//

import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
public struct PODynamicCheckoutView: View {

    init(viewModel: @autoclosure @escaping () -> some DynamicCheckoutViewModel) {
        self._viewModel = .init(wrappedValue: .init(erasing: viewModel()))
    }

    // MARK: - View

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: true) {
                DynamicCheckoutContentView(sections: viewModel.state.sections)
            }
            .clipped()
            .backport.geometryGroup()
            if !viewModel.state.actions.isEmpty {
                POActionsContainerView(actions: viewModel.state.actions)
                    .actionsContainerStyle(style.actionsContainer)
            }
        }
        .backport.background {
            let backgroundColor = viewModel.state.isCompleted ? style.success.backgroundColor : style.backgroundColor
            backgroundColor
                .ignoresSafeArea()
                .animation(.default, value: viewModel.state.isCompleted)
        }
        .onAppear(perform: viewModel.start)
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @StateObject
    private var viewModel: AnyDynamicCheckoutViewModel

    @Environment(\.dynamicCheckoutStyle)
    private var style
}

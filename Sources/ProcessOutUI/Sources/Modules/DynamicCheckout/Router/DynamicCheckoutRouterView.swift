//
//  DynamicCheckoutRouterView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 26.04.2024.
//

import Foundation
import SwiftUI

@available(iOS 14.0, *)
struct DynamicCheckoutRouterView: View {

    let route: DynamicCheckoutRoute

    /// Router delegate.
    unowned let delegate: DynamicCheckoutRouterDelegate

    // MARK: - View

    var body: some View {
        switch route {
        case .card:
            let viewModel: () -> DefaultCardTokenizationViewModel = {
                let interactor = delegate.routerWillRouteToCardTokenization()
                return DefaultCardTokenizationViewModel(interactor: interactor)
            }
            ContentBox(value: viewModel()) { viewModel in
                CardTokenizationContentView(viewModel: viewModel)
            }
            .cardTokenizationStyle(POCardTokenizationStyle(dynamicCheckoutStyle: style))
        case .nativeAlternativePayment(let id):
            let viewModel: () -> DefaultNativeAlternativePaymentViewModel = {
                let interactor = delegate.routerWillRouteToNativeAlternativePayment(with: id)
                return DefaultNativeAlternativePaymentViewModel(interactor: interactor)
            }
            ContentBox(value: viewModel()) { viewModel in
                NativeAlternativePaymentContentView(viewModel: viewModel)
            }
            .nativeAlternativePaymentStyle(PONativeAlternativePaymentStyle(dynamicCheckoutStyle: style))
        }
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}

@available(iOS 14.0, *)
private struct ContentBox<T: ObservableObject, Content: View>: View {

    init(value: @autoclosure @escaping () -> T, content: @escaping (T) -> Content) {
        self.content = content
        self._value = .init(wrappedValue: value())
    }

    var body: some View {
        content(value)
    }

    // MARK: -

    private let content: (T) -> Content

    @StateObject
    private var value: T
}

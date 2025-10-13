//
//  PONativeAlternativePaymentView+Init.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

@_spi(PO) import ProcessOut

extension PONativeAlternativePaymentView {

    /// Creates native alternative payment view.
    ///
    /// - Parameters:
    ///   - completion: Completion to invoke when flow is completed.
    ///
    /// - NOTE: Use caution when using this view, because SwiftUI only initializes
    /// its state once during the lifetime of the view — even if you call the initializer
    /// more than once — which might result in unexpected behavior.
    public init(
        configuration: PONativeAlternativePaymentConfiguration,
        delegate: PONativeAlternativePaymentDelegateV2? = nil,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        self.init(component: .init(configuration: configuration, delegate: delegate, completion: completion))
    }

    /// Creates native alternative payment view.
    ///
    /// - NOTE: Use caution when using this view, because SwiftUI only initializes
    /// its state once during the lifetime of the view — even if you call the initializer
    /// more than once — which might result in unexpected behavior.
    public init(component: @escaping @autoclosure () -> PONativeAlternativePaymentComponent) {
        let viewModel = {
            DefaultNativeAlternativePaymentViewModel(interactor: component().interactor)
        }
        self = .init(viewModel: viewModel())
    }

    /// Creates native alternative payment view.
    ///
    /// - Parameters:
    ///   - completion: Completion to invoke when flow is completed.
    ///
    /// - NOTE: Use caution when using this view, because SwiftUI only initializes
    /// its state once during the lifetime of the view — even if you call the initializer
    /// more than once — which might result in unexpected behavior.
    @_disfavoredOverload
    @available(*, deprecated)
    public init(
        configuration: PONativeAlternativePaymentConfiguration,
        delegate: PONativeAlternativePaymentDelegate? = nil,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        self.init(configuration: configuration, delegate: nil, completion: completion)
    }
}

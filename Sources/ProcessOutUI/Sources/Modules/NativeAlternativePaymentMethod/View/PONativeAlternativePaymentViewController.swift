//
//  PONativeAlternativePaymentViewController.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

import SwiftUI
import ProcessOut

/// View controller hosting `PONativeAlternativePaymentView`.
@available(iOS 14, *)
public final class PONativeAlternativePaymentViewController: UIHostingController<AnyView> {

    /// Creates native APM view controller.
    public init(
        style: PONativeAlternativePaymentStyle = .default,
        invoiceId: String,
        gatewayConfigurationId: String,
        configuration: PONativeAlternativePaymentConfiguration = .init(),
        delegate: PONativeAlternativePaymentMethodDelegate? = nil,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        let view = PONativeAlternativePaymentView(
            invoiceId: invoiceId,
            gatewayConfigurationId: gatewayConfigurationId,
            configuration: configuration,
            delegate: delegate,
            completion: completion
        )
        super.init(rootView: AnyView(view.nativeAlternativePaymentStyle(style)))
    }

    @available(*, unavailable)
    public dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

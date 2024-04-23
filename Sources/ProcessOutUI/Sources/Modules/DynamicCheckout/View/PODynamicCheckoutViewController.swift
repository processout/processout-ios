//
//  PODynamicCheckoutViewController.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 16.04.2024.
//

import SwiftUI
import ProcessOut

/// View controller hosting `PODynamicCheckoutView`.
@available(iOS 14, *)
public final class PODynamicCheckoutViewController: UIHostingController<AnyView> {

    /// Creates card tokenization view controller.
    public init(
        style: PODynamicCheckoutStyle = PODynamicCheckoutStyle(),
        configuration: PODynamicCheckoutConfiguration,
        delegate: PODynamicCheckoutDelegate,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        let view = PODynamicCheckoutView(configuration: configuration, delegate: delegate, completion: completion)
            .dynamicCheckoutStyle(style)
        super.init(rootView: AnyView(view))
    }

    @available(*, unavailable)
    public dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  POCardTokenizationViewController.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 09.11.2023.
//

import SwiftUI
import ProcessOut

/// View controller hosting `POCardTokenizationView`.
@available(iOS 14, *)
public final class POCardTokenizationViewController: UIHostingController<AnyView> {

    /// Creates card tokenization view controller.
    public init(
        style: POCardTokenizationStyle = .default,
        configuration: POCardTokenizationConfiguration = .init(),
        delegate: POCardTokenizationDelegate? = nil,
        completion: @escaping (Result<POCard, POFailure>) -> Void
    ) {
        let view = POCardTokenizationView(configuration: configuration, delegate: delegate, completion: completion)
            .cardTokenizationStyle(style)
        super.init(rootView: AnyView(view))
    }

    @available(*, unavailable)
    public dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

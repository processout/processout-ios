//
//  POCardUpdateViewController.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 09.11.2023.
//

import SwiftUI
import ProcessOut

/// View controller hosting `POCardUpdateView`.
public final class POCardUpdateViewController: UIHostingController<AnyView> {

    /// Creates card tokenization view controller.
    public init(
        style: POCardUpdateStyle = .default,
        configuration: POCardUpdateConfiguration,
        delegate: POCardUpdateDelegate? = nil,
        completion: @escaping (Result<POCard, POFailure>) -> Void
    ) {
        let view = POCardUpdateView(configuration: configuration, delegate: delegate, completion: completion)
            .cardUpdateStyle(style)
        super.init(rootView: AnyView(view))
    }

    @available(*, unavailable)
    public dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

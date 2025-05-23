//
//  POCheckout3DSServiceBuilder.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 01.03.2023.
//

import Foundation
import ProcessOut
import Checkout3DS

/// Builder to configure and create service capable of handling 3DS challenges using Checkout3DS SDK.
@available(*, deprecated, message: "Instantiate POCheckout3DSService directly.")
public final class POCheckout3DSServiceBuilder {

    /// - NOTE: Delegate will be strongly referenced by created service.
    @available(*, deprecated, message: "Use non static method instead.")
    public static func with(delegate: POCheckout3DSServiceDelegate) -> POCheckout3DSServiceBuilder {
        POCheckout3DSServiceBuilder().with(delegate: delegate)
    }

    /// Creates builder instance.
    public init() {
        environment = .production
    }

    /// - NOTE: Delegate will be strongly referenced by created service.
    public func with(delegate: POCheckout3DSServiceDelegate) -> Self {
        self.delegate = delegate
        return self
    }

    /// Sets environment used to initialize `Standalone3DSService`. Default value is `production`.
    public func with(environment: Checkout3DS.Environment) -> Self {
        self.environment = environment
        return self
    }

    /// Creates service instance.
    public func build() -> PO3DSService {
        ThreeDSServiceAdapter(service: POCheckout3DSService(delegate: delegate, environment: environment))
    }

    // MARK: - Private Properties

    private var delegate: POCheckout3DSServiceDelegate?
    private var environment: Checkout3DS.Environment
}

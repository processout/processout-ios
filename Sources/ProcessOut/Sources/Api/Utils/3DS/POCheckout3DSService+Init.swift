//
//  POCheckout3DSService+Init.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.09.2025.
//

#if canImport(ProcessOutCheckout3DS)

import ProcessOutCheckout3DS
import Checkout3DS

extension POCheckout3DSService {

    /// Creates service instance.
    public nonisolated convenience init(
        delegate: POCheckout3DSServiceDelegate? = nil,
        environment: Environment = .production,
        processOut: ProcessOut = .shared
    ) {
        self.init(delegate: delegate, environment: environment, eventEmitter: processOut.eventEmitter)
    }
}

#endif // canImport(ProcessOutCheckout3DS)

//
//  PONetcetera3DS2Service+Init.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.09.2025.
//

#if canImport(ProcessOutNetcetera3DS)

import ProcessOutNetcetera3DS

extension PONetcetera3DS2Service {

    /// Creates service instance.
    public init(
        configuration: PONetcetera3DS2ServiceConfiguration = .init(),
        delegate: PONetcetera3DS2ServiceDelegate? = nil,
        processOut: ProcessOut = .shared
    ) {
        self.init(configuration: configuration, delegate: delegate, eventEmitter: processOut.eventEmitter)
    }
}

#endif // canImport(ProcessOutNetcetera3DS)

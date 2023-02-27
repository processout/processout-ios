//
//  HttpConnectorRetryDecoratorOperationState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.02.2023.
//

import Foundation

enum HttpConnectorRetryDecoratorOperationState {

    struct Executing {

        /// Operation cancellable.
        let cancellable: POCancellableType

        /// Total retries count.
        let retryCount: Int
    }

    case idle, executing(Executing), waiting(Timer), completed
}

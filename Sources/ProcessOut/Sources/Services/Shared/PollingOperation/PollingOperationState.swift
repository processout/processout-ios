//
//  PollingOperationState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.02.2023.
//

import Foundation

enum PollingOperationState {

    struct Executing {

        /// General timeout timer.
        let timeoutTimer: Timer

        /// Operation cancellable.
        let cancellable: POCancellable
    }

    struct Waiting {

        /// General timeout timer.
        let timeoutTimer: Timer

        /// Wait timer.
        let waitTimer: Timer
    }

    case idle, executing(Executing), waiting(Waiting), completed
}

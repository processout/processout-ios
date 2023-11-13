//
//  CardUpdateInteractorState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

import Foundation
import ProcessOut

enum CardUpdateInteractorState {

    struct Started {

        /// Masked card number.
        var cardNumber: String?

        /// Card scheme.
        var scheme: String?

        /// Current CVC value.
        var cvc: String = ""

        /// Formatter that should be used to format CVC.
        var formatter: Formatter?

        /// The most recent error message.
        var recentErrorMessage: String?
    }

    case idle

    /// Interactor is currently starting.
    case starting

    /// Interactor has started and is ready.
    case started(Started)

    /// Card information is currently being updated.
    case updating(snapshot: Started)

    /// Card update has finished. This is a sink state.
    case completed
}

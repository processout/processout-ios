//
//  NativeAlternativePaymentInteractorState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.02.2024.
//

import Foundation
import Combine
import UIKit
@_spi(PO) import ProcessOut

enum NativeAlternativePaymentInteractorState {

    struct Starting {

        /// Start task.
        let task: Task<Void, Never>
    }

    struct Started {

        /// Parameters that are expected from user.
        var parameters: [Parameter]

        /// Boolean value indicating whether user should be able to manually cancel payment in current state.
        var isCancellable: Bool
    }

    struct Submitting {

        /// Started state snapshot.
        let snapshot: Started

        /// Submission task.
        let task: Task<Void, Never>
    }

    struct AwaitingRedirect {

        /// Redirect information.
        let redirect: PONativeAlternativePaymentNextStepV2.Redirect
    }

    struct Redirecting {

        /// Awaiting redirect state snapshot.
        let snapshot: AwaitingRedirect
    }

    struct AwaitingCapture {

        /// Additional customer instructions.
        let customerInstructions: [NativeAlternativePaymentResolvedCustomerInstruction]

        /// Boolean value indicating whether user should be able to manually cancel payment in current state.
        var isCancellable: Bool

        /// Capture task if any.
        /// - NOTE: For internal use by interactor only.
        var task: Task<Void, Never>?

        /// Boolean value indicating whether capture takes longer than anticipated.
        var isDelayed: Bool

        /// Boolean value indicating whether payment should be manually confirmed by user to start capture.
        var shouldConfirmCapture: Bool
    }

    struct Captured {

        /// Additional customer instructions.
        let customerInstructions: [NativeAlternativePaymentResolvedCustomerInstruction]

        /// Task that handles completion invocation.
        let completionTask: Task<Void, Never>
    }

    struct Parameter {

        /// Parameter specification that includes but not limited to its type, length, name etc.
        let specification: PONativeAlternativePaymentNextStepV2.SubmitData.Parameter

        /// Formatter that could be used to format parameter.
        let formatter: Formatter?

        /// Actual parameter value.
        var value: ParameterValue?

        /// The most recent error message associated with this parameter value.
        var recentErrorMessage: String?
    }

    enum ParameterValue: Equatable {

        struct Phone: Equatable { // swiftlint:disable:this nesting

            /// Selected region code.
            let regionCode: String?

            /// National phone number value.
            let number: String?
        }

        case string(String), phone(Phone)
    }

    /// Initial interactor state.
    case idle

    /// Interactor is loading initial content portion.
    case starting(Starting)

    /// Interactor is started and awaits for parameters values.
    case started(Started)

    /// Starting failure. This is a sink state.
    case failure(POFailure)

    /// Parameter values are being submitted.
    case submitting(Submitting)

    /// Interactor is awaiting for redirect.
    case awaitingRedirect(AwaitingRedirect)

    /// User is currently being redirected.
    case redirecting(Redirecting)

    /// Parameters were submitted and accepted.
    case awaitingCapture(AwaitingCapture)

    /// Payment is completed.
    case captured(Captured)
}

extension NativeAlternativePaymentInteractorState.Started {

    /// Boolean value that allows to determine whether all parameters are valid.
    var areParametersValid: Bool {
        parameters.allSatisfy { $0.recentErrorMessage == nil }
    }
}

extension NativeAlternativePaymentInteractorState: InteractorState {

    var isSink: Bool {
        switch self {
        case .captured, .failure:
            return true
        default:
            return false
        }
    }
}

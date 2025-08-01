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

        /// Payment method information.
        var paymentMethod: NativeAlternativePaymentResolvedPaymentMethod

        /// Invoice information if any.
        let invoice: PONativeAlternativePaymentInvoiceV2?

        /// Elements.
        var elements: [NativeAlternativePaymentResolvedElement]

        /// Parameters that are expected from user.
        var parameters: [String: Parameter]

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

        /// Payment method information.
        let paymentMethod: NativeAlternativePaymentResolvedPaymentMethod

        /// Invoice information if any.
        let invoice: PONativeAlternativePaymentInvoiceV2?

        /// Resolved elements.
        let elements: [NativeAlternativePaymentResolvedElement]

        /// Redirect information.
        let redirect: PONativeAlternativePaymentRedirectV2

        /// Boolean value indicating whether user should be able to manually cancel payment in current state.
        var isCancellable: Bool
    }

    struct Redirecting {

        /// Task associated with operation that actually handles the redirect.
        let task: Task<Void, Never>

        /// Awaiting redirect state snapshot.
        let snapshot: AwaitingRedirect
    }

    struct AwaitingCompletion {

        /// Payment method information.
        let paymentMethod: NativeAlternativePaymentResolvedPaymentMethod

        /// Invoice information if any.
        let invoice: PONativeAlternativePaymentInvoiceV2?

        /// Resolved elements.
        let elements: [NativeAlternativePaymentResolvedElement]

        /// Date when payment is expected to be completed.
        var estimatedCompletionDate: Date?

        /// Boolean value indicating whether user should be able to manually cancel payment in current state.
        var isCancellable: Bool

        /// Completion confirmation task if any.
        /// - NOTE: For internal use by interactor only.
        var task: Task<Void, Never>?

        /// Boolean value indicating whether payment should be manually confirmed by user to continue.
        var shouldConfirmPayment: Bool
    }

    struct Completed {

        /// Payment method information.
        let paymentMethod: NativeAlternativePaymentResolvedPaymentMethod

        /// Invoice information if any.
        let invoice: PONativeAlternativePaymentInvoiceV2?

        /// Resolved elements.
        let elements: [NativeAlternativePaymentResolvedElement]

        /// Task that handles completion invocation.
        let completionTask: Task<Void, Never>
    }

    struct Parameter {

        /// Parameter specification that includes but not limited to its type, length, name etc.
        let specification: PONativeAlternativePaymentFormV2.Parameter

        /// Formatter that could be used to format parameter.
        let formatter: Formatter?

        /// Actual parameter value.
        var value: PONativeAlternativePaymentParameterValue?

        /// The most recent error message associated with this parameter value.
        var recentErrorMessage: String?
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
    case awaitingCompletion(AwaitingCompletion)

    /// Payment is completed.
    case completed(Completed)
}

extension NativeAlternativePaymentInteractorState.Started {

    /// Boolean value that allows to determine whether all parameters are valid.
    var areParametersValid: Bool {
        parameters.values.allSatisfy { $0.recentErrorMessage == nil }
    }
}

extension NativeAlternativePaymentInteractorState: InteractorState {

    var isSink: Bool {
        switch self {
        case .completed, .failure:
            return true
        default:
            return false
        }
    }
}

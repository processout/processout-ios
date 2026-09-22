//
//  AlternativePaymentMethodsViewModelType.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import Foundation
import SwiftUI
import ProcessOut
import ProcessOutUI

struct AlternativePaymentsViewModelState {

    /// Describes how payment is expected to be finalized once all customer actions are completed.
    enum FinalizationMode: String, Hashable {

        /// Backend decides how to finalize payment.
        case automatic

        /// Payment is expected to be manually advanced to an authorized state.
        case authorization

        /// Payment is expected to be manually captured.
        case capture
    }

    enum Flow: String, Hashable {

        /// One time payment.
        case payment

        /// Payment method should be tokenized.
        case tokenization

        /// Combined payment and tokenization.
        case combined
    }

    struct GatewayConfiguration: Identifiable {

        /// Item identifier.
        let id: String

        /// Configuration name.
        let name: String
    }

    struct Filter: Identifiable {

        /// Filter ID.
        let id: POAllGatewayConfigurationsRequest.Filter

        /// Filter name.
        let name: String
    }

    struct NativePayment: Identifiable {

        let id: String

        /// Payment component.
        let component: PONativeAlternativePaymentComponent
    }

    /// Invoice details.
    var invoice = InvoiceViewModel()

    /// Gateway configuration.
    var filter: Binding<PickerData<Filter, POAllGatewayConfigurationsRequest.Filter>>?

    /// Gateway configuration.
    var gatewayConfiguration: PickerData<GatewayConfiguration, String>?

    /// Boolean value indicating whether native flow should be preferred if available.
    var preferNative = false

    // swiftlint:disable implicitly_unwrapped_optional

    /// Payment flow.
    var flow: PickerData<Flow, Flow>!

    /// Mode that describes how payment is finalized once all customer actions are completed.
    var finalizationMode: PickerData<FinalizationMode, FinalizationMode>!

    // swiftlint:enable implicitly_unwrapped_optional

    /// Currently presented native alternative payment.
    var nativePayment: NativePayment?

    /// Message.
    var message: MessageViewModel?
}

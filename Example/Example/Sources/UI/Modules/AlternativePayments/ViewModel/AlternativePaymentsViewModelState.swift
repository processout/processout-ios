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

    /// Payment flow.
    var flow: PickerData<Flow, Flow>! // swiftlint:disable:this implicitly_unwrapped_optional

    /// Currently presented native alternative payment.
    var nativePayment: NativePayment?

    /// Message.
    var message: MessageViewModel?
}

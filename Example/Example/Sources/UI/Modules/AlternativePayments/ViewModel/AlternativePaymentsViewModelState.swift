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

        /// Configuration.
        let configuration: PONativeAlternativePaymentConfiguration

        /// Completion.
        let completion: (Result<Void, POFailure>) -> Void
    }

    /// Invoice details.
    var invoice = InvoiceViewModel()

    /// Gateway configuration.
    var filter: Binding<PickerData<Filter, POAllGatewayConfigurationsRequest.Filter>>?

    /// Gateway configuration.
    var gatewayConfiguration: PickerData<GatewayConfiguration, String>?

    /// Boolean value indicating whether native flow should be preferred if available.
    var preferNative = false

    /// Currently presented native alternative payment.
    var nativePayment: NativePayment?

    /// Message.
    var message: MessageViewModel?
}

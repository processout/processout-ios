//
//  PODynamicCheckoutDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import ProcessOut

public protocol PODynamicCheckoutDelegate: AnyObject {

    /// Invoked when module emits dynamic checkout event.
    func dynamicCheckout(didEmitEvent event: PODynamicCheckoutEvent)
}

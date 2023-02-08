//
//  PONativeAlternativePaymentMethodDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.02.2023.
//

/// Native alternative payment module delegate definition.
public protocol PONativeAlternativePaymentMethodDelegate: AnyObject {

    /// Invoked when module emits event. Default implementatioin does nothing.
    func nativeAlternativePaymentMethodDidEmitEvent(_ event: PONativeAlternativePaymentMethodEvent)
}

extension PONativeAlternativePaymentMethodDelegate {

    public func nativeAlternativePaymentMethodDidEmitEvent(_ event: PONativeAlternativePaymentMethodEvent) {
        /* NOP */
    }
}

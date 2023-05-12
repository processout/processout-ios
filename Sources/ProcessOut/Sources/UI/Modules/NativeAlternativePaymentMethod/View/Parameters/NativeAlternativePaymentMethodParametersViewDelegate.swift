//
//  NativeAlternativePaymentMethodParametersViewDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.12.2022.
//

// swiftlint:disable:next type_name
protocol NativeAlternativePaymentMethodParametersViewDelegate: AnyObject {

    /// Asks delegate if editing should begin.
    func shouldBeginEditing(view: NativeAlternativePaymentMethodParametersView) -> Bool

    /// User completed parameters editing and requests to submit input.
    func didCompleteParametersEditing(view: NativeAlternativePaymentMethodParametersView)
}

//
//  NativeAlternativePaymentMethodViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.04.2023.
//

@available(*, deprecated)
protocol NativeAlternativePaymentMethodViewModel: ViewModel<NativeAlternativePaymentMethodViewModelState> {

    /// Submits parameter values.
    func submit()
}

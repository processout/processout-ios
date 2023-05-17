//
//  NativeAlternativePaymentMethodViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.04.2023.
//

protocol NativeAlternativePaymentMethodViewModel: ViewModel<NativeAlternativePaymentMethodViewModelState> {

    /// Submits parameter values.
    func submit()
}

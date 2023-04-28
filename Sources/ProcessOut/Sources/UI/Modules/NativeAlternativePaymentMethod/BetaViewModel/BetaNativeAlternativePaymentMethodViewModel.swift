//
//  BetaNativeAlternativePaymentMethodViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.04.2023.
//

protocol BetaNativeAlternativePaymentMethodViewModel: ViewModel<BetaNativeAlternativePaymentMethodViewModelState> {

    /// Submits parameter values.
    func submit()
}

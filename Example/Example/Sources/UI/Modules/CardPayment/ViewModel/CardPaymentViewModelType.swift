//
//  CardPaymentViewModelType.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.03.2023.
//

import Foundation

protocol CardPaymentViewModelType: ViewModelType<CardPaymentViewModelState> {

    /// Initiates card payment.
    func pay()
}

enum CardPaymentViewModelState {

    struct Started {

        /// Card number.
        let cardNumber: String

        /// Card expiration date.
        let expirationDate: String

        /// Card expiration date.
        let cvc: String
    }

    case idle, started(Started)
}

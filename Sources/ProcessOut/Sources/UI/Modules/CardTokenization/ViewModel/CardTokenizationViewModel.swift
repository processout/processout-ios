//
//  CardTokenizationViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.07.2023.
//

// TODOs:
// - Decide whether module should allow to collect custom parameters specified by merchant
// - Support invoice authorization as an option
//   * Maybe allow user to decide whether he wants save card for future payments
// - Support token assignment as an option
// - Add an ability to hide title
// - Support scanning card details with camera
// - Allow selecting card co-scheme when authorizing invoice or assigning token
// - Add icons to card input and cvc fields
// - Decide whether we need to collect additional information except card details

protocol CardTokenizationViewModel: ViewModel<CardTokenizationViewModelState> {

    /// Submits tokenization request.
    func submit()
}

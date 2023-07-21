//
//  CardTokenizationViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.07.2023.
//

import UIKit

protocol CardTokenizationViewModel: ViewModel<CardTokenizationViewModelState> {

    /// Submits tokenization request.
    func submit()
}

// TITLE
// DESCRIPTION ?
// ----
// CARD INFORMATION SECTION
// CARD NUMBER
// EXP DATE (month + year) -> CVC
// CARDHOLDER NAME
// ----
// SUBMIT
// CANCEL ?

// 1. also support asking some custom arguments ?
// 2. maybe checkbox indicating whether card should be saved for future payments ? this should be embedded
// 3. maybe use swiftui and provide view controller backport ?
// 4. Card can't be authorized instead support assigning it to token (checkbox mentioned in 2)
// 5. Support card formatting
// 6. Support showing card scheme logos
// 7. It should be possible for user to select card co-scheme
// 8. Support scanning card details
// 9. Maybe accept contact information and metadata?
// 10. Allow to authorize invoice or payment token if asked

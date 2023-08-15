//
//  CardTokenizationViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.07.2023.
//

protocol CardTokenizationViewModel: ViewModel<CardTokenizationViewModelState> {

    /// Invoked when view appears on screen.
    func didAppear()
}

// TODOs:
// - Decide whether module should allow to collect custom parameters specified by merchant
// - Support scanning card details with camera
// - Allow selecting card co-scheme when authorizing invoice or assigning token
// - Decide whether we need to collect additional information except card details

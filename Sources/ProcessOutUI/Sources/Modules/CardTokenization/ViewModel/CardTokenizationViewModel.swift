//
//  CardTokenizationViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 13.07.2023.
//

import Foundation
import Combine

protocol CardTokenizationViewModel: ObservableObject {

    typealias State = CardTokenizationViewModelState

    /// Current state.
    var state: State { get set }
}

// TODOs:
// - Support scanning card details with camera
// - Allow selecting card co-scheme when authorizing invoice or assigning token

//
//  ViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 05.06.2024.
//

import Combine

protocol ViewModel<State>: ObservableObject {

    associatedtype State

    /// View model's state.
    var state: State { get set }

    /// Starts view model.
    func start()
}

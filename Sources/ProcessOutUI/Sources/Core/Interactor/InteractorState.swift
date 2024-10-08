//
//  InteractorState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.10.2024.
//

protocol InteractorState {

    /// Boolean variable that indicates whether the current state is a sink state.
    ///
    /// A sink state is a special kind of state where, once entered, no other state transitions are possible.
    var isSink: Bool { get }
}

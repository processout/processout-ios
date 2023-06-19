//
//  EventEmitterEvent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

protocol EventEmitterEvent: Sendable {

    /// Event name.
    static var name: String { get }
}

extension EventEmitterEvent {

    public static var name: String {
        String(describing: self)
    }
}

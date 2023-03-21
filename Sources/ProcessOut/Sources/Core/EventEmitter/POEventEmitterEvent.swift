//
//  POEventEmitterEvent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.01.2023.
//

public protocol POEventEmitterEvent: Sendable {

    /// Event name.
    static var name: String { get }
}

extension POEventEmitterEvent {

    public static var name: String {
        String(describing: self)
    }
}

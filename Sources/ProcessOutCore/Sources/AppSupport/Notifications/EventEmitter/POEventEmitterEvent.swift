//
//  POEventEmitterEvent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

package protocol POEventEmitterEvent: Sendable {

    /// Event name.
    static var name: String { get }
}

extension POEventEmitterEvent {

    package static var name: String {
        String(describing: self)
    }
}

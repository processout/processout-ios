//
//  POEventEmitter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

import Foundation

@_spi(PO)
public protocol POEventEmitter: Sendable {

    /// Emits given event.
    @discardableResult
    func emit<Event: POEventEmitterEvent>(event: Event) -> Bool

    /// Adds subscription for given event.
    func on<Event: POEventEmitterEvent>(
        _ eventType: Event.Type, listener: @escaping @Sendable (Event) -> Bool
    ) -> AnyObject

    /// Returns boolean value indicating whether there are currently any listeners
    /// of event with given type.
    func hasListeners<Event: POEventEmitterEvent>(of eventType: Event.Type) -> Bool
}

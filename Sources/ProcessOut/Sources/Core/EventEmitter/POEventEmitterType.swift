//
//  POEventEmitterType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.01.2023.
//

@_spi(PO)
public protocol POEventEmitterType: Sendable {

    /// Emits given event.
    func emit<Event: POEventEmitterEvent>(event: Event) -> Bool

    /// Adds subscription for given event.
    func on<Event: POEventEmitterEvent>(_ eventType: Event.Type, listener: @escaping (Event) -> Bool) -> AnyObject
}

//
//  EventEmitter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

import Foundation

protocol EventEmitter: Sendable {

    /// Emits given event.
    func emit<Event: EventEmitterEvent>(event: Event) -> Bool

    /// Adds subscription for given event.
    func on<Event: EventEmitterEvent>(_ eventType: Event.Type, listener: @escaping (Event) -> Bool) -> AnyObject
}

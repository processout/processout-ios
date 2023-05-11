//
//  LocalEventEmitter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

import Foundation

final class LocalEventEmitter: EventEmitter, @unchecked Sendable {

    init() {
        lock = NSLock()
        subscriptions = [:]
    }

    // MARK: - EventEmitter

    func emit<Event: EventEmitterEvent>(event: Event) -> Bool {
        lock.lock()
        guard let eventSubscriptions = subscriptions[Event.name]?.values else {
            lock.unlock()
            return false
        }
        lock.unlock()
        guard !eventSubscriptions.isEmpty else {
            return false
        }
        var isHandled = false
        for subscription in eventSubscriptions {
            // Event should be delievered to all subscribers.
            isHandled = subscription.listener(event) || isHandled
        }
        return isHandled
    }

    func on<Event: EventEmitterEvent>(_ eventType: Event.Type, listener: @escaping (Event) -> Bool) -> AnyObject {
        let subscription = Subscription { event in
            guard let event = event as? Event else {
                return false
            }
            return listener(event)
        }
        let subscriptionId = UUID().uuidString
        lock.lock()
        if subscriptions[Event.name] != nil {
            subscriptions[Event.name]?[subscriptionId] = subscription
        } else {
            subscriptions[Event.name] = [subscriptionId: subscription]
        }
        lock.unlock()
        let cancellable = Cancellable { [weak self] in
            guard let self = self else {
                return
            }
            self.lock.lock()
            self.subscriptions[Event.name]?[subscriptionId] = nil
            self.lock.unlock()
        }
        return cancellable
    }

    // MARK: - Private Nested Types

    private struct Subscription {

        /// Type erased listener.
        let listener: (Any) -> Bool
    }

    private final class Cancellable {

        let didCancel: () -> Void

        init(didCancel: @escaping () -> Void) {
            self.didCancel = didCancel
        }

        deinit {
            didCancel()
        }
    }

    // MARK: - Private Properties

    private let lock: NSLock
    private var subscriptions: [String: [AnyHashable: Subscription]]
}

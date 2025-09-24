//
//  LocalEventEmitter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

import Foundation

package final class LocalEventEmitter: POEventEmitter, @unchecked Sendable {

    package init(logger: POLogger) {
        self.logger = logger
        lock = NSLock()
        subscriptions = [:]
    }

    // MARK: - POEventEmitter

    package func emit<Event: POEventEmitterEvent>(event: Event) -> Bool {
        lock.lock()
        guard let eventSubscriptions = subscriptions[Event.name]?.values, !eventSubscriptions.isEmpty else {
            lock.unlock()
            logger.debug("No subscribers for '\(Event.name)' event, ignored")
            return false
        }
        lock.unlock()
        var isHandled = false
        for subscription in eventSubscriptions {
            // Event should be delivered to all subscribers.
            isHandled = subscription.listener(event) || isHandled
        }
        if !isHandled {
            logger.debug("Subscribers refused to handle '\(Event.name)' event")
        }
        return isHandled
    }

    package func on<Event: POEventEmitterEvent>(
        _ eventType: Event.Type, listener: @escaping @Sendable (Event) -> Bool
    ) -> AnyObject {
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

    private let logger: POLogger
    private let lock: NSLock
    private var subscriptions: [String: [AnyHashable: Subscription]]
}

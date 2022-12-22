//
//  GroupCancellable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.12.2022.
//

import Foundation

final class GroupCancellable: POCancellableType {

    init() {
        isCancelled = false
        lock = NSLock()
        cancellables = []
    }

    func add(_ cancellable: POCancellableType) {
        if isCancelled {
            cancellable.cancel()
        } else {
            lock.withLock { cancellables.append(cancellable) }
        }
    }

    func cancel() {
        lock.lock()
        guard !isCancelled else {
            lock.unlock()
            return
        }
        isCancelled = true
        let cancellables = self.cancellables
        self.cancellables = []
        lock.unlock()
        cancellables.forEach { $0.cancel() }
    }

    // MARK: - Private Properties

    private let lock: NSLock
    private var isCancelled: Bool
    private var cancellables: [POCancellableType]
}

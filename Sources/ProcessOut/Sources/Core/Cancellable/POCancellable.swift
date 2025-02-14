//
//  POCancellable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.12.2022.
//

@available(*, deprecated, renamed: "POCancellable")
public typealias POCancellableType = POCancellable

/// A protocol indicating that an activity or action supports cancellation.
@available(*, deprecated)
public protocol POCancellable: Sendable {

    /// Cancel the activity.
    func cancel()
}

@available(*, deprecated)
extension Task: POCancellable { }

//
//  POCancellable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.12.2022.
//

@available(*, deprecated, renamed: "POCancellable")
public typealias POCancellableType = POCancellable

/// A protocol indicating that an activity or action supports cancellation.
@available(*, deprecated, message: "No longer used.")
public protocol POCancellable {

    /// Cancel the activity.
    func cancel()
}

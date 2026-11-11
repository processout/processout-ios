//
//  Task+Cancellation.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 28.09.2026.
//

extension Task where Success == Never, Failure == Never {

    /// Throws cancellation failure if the current task has been cancelled.
    @_spi(PO)
    public static func poCheckCancellation() throws(POFailure) {
        guard Task.isCancelled else {
            return
        }
        throw POFailure(
            message: "Task was cancelled.",
            code: .Mobile.cancelled,
            underlyingError: Swift.CancellationError()
        )
    }
}

//
//  Task+Sleep.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.05.2024.
//

import Foundation

extension Task where Success == Never, Failure == Never {

    /// Suspends the current task for at least the given duration in seconds.
    @_spi(PO)
    public static func sleep(seconds: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(TimeInterval(NSEC_PER_SEC) * seconds))
    }
}

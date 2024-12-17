//
//  DispatchTime+UptimeSeconds.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.12.2024.
//

import Foundation

extension DispatchTime {

    /// Returns the number of seconds since boot, excluding any time the system spent asleep.
    @_spi(PO)
    public var uptimeSeconds: TimeInterval {
        TimeInterval(uptimeNanoseconds) / TimeInterval(NSEC_PER_SEC)
    }
}

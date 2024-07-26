//
//  POService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

/// Common protocol that all services conform to.
public protocol POService: Sendable {

    /// Service's failure type.
    typealias Failure = POFailure
}

@available(*, deprecated, renamed: "POService")
public typealias POServiceType = POService

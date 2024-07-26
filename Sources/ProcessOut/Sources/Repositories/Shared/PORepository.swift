//
//  PORepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

@available(*, deprecated, renamed: "PORepository")
public typealias PORepositoryType = PORepository

/// Common protocol that all repositories conform to.
public protocol PORepository: Sendable {

    /// Repository's failure type.
    typealias Failure = POFailure
}

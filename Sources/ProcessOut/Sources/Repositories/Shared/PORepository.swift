//
//  PORepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

@available(*, deprecated, renamed: "PORepository")
public typealias PORepositoryType = PORepository

// todo(andrii-vysotskyi): remove conformance to POAutoCompletion when services are migrated
/// Common protocol that all repositories conform to.
public protocol PORepository: POAutoCompletion {

    /// Repository's failure type.
    typealias Failure = POFailure
}

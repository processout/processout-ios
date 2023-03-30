//
//  POServiceType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

/// Common protocol that all services conform to.
public protocol POServiceType: POAutoAsync {

    /// Service's failure type.
    typealias Failure = POFailure
}

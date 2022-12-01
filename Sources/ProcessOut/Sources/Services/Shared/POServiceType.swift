//
//  POServiceType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

public protocol POServiceType: POAutoAsync {

    /// Service's failure type.
    typealias Failure = POFailure
}

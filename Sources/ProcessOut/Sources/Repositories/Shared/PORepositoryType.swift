//
//  PORepositoryType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

public protocol PORepositoryType: POAutoAsync {

    /// Repository's failure type.
    typealias Failure = PORepositoryFailure
}

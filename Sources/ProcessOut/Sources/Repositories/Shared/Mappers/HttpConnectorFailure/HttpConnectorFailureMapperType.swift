//
//  HttpConnectorFailureMapperType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.10.2022.
//

protocol HttpConnectorFailureMapperType {

    /// Creates repository failure with given ``HttpConnectorFailure`` instance.
    func failure(from failure: HttpConnectorFailure) -> POFailure
}

//
//  HttpConnectorFailureMapper.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.10.2022.
//

protocol HttpConnectorFailureMapper {

    /// Creates repository failure with given ``HttpConnectorFailure`` instance.
    func failure(from failure: HttpConnectorFailure) -> POFailure
}

//
//  HttpConnectorFailureMapper.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.10.2022.
//

protocol HttpConnectorFailureMapper: Sendable {

    /// Creates `POFailure` with given ``HttpConnectorFailure`` instance.
    func failure(from failure: HttpConnectorFailure) -> POFailure
}

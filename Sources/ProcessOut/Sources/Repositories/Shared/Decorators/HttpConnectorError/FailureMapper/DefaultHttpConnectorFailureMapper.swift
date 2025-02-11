//
//  DefaultHttpConnectorFailureMapper.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.10.2022.
//

import Foundation

final class DefaultHttpConnectorFailureMapper: HttpConnectorFailureMapper {

    init(logger: POLogger) {
        self.logger = logger
    }

    // MARK: - HttpConnectorFailureMapper

    func failure(from failure: HttpConnectorFailure) -> POFailure {
        let message: String?, code: POFailureCode, invalidFields: [POFailure.InvalidField]?
        switch failure.code {
        case .decoding, .encoding, .internal:
            message = "An unexpected error occurred while processing your request."
            code = .Mobile.internal
            invalidFields = nil
        case .networkUnreachable:
            message = "Request can't be processed because there is no network connection."
            code = .Mobile.networkUnreachable
            invalidFields = nil
        case .timeout:
            message = "Request timed out."
            code = .Mobile.timeout
            invalidFields = nil
        case .cancelled:
            message = "Request was cancelled."
            code = .Mobile.cancelled
            invalidFields = nil
        case let .server(error, _):
            message = error.message
            code = .init(rawValue: error.errorType)
            invalidFields = error.invalidFields?.map { .init(name: $0.name, message: $0.message) }
        }
        return POFailure(message: message, code: code, invalidFields: invalidFields, underlyingError: failure)
    }

    // MARK: - Private Properties

    private let logger: POLogger
}

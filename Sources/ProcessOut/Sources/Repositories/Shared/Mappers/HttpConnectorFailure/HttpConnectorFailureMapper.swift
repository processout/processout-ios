//
//  HttpConnectorFailureMapper.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.10.2022.
//

import Foundation

final class HttpConnectorFailureMapper: HttpConnectorFailureMapperType {

    func failure(from failure: HttpConnectorFailure) -> POFailure {
        let message: String?
        let code: POFailure.Code?
        let invalidFields: [POFailure.InvalidField]?
        switch failure {
        case .coding, .internal:
            message = "An unexpected error occurred while processing your request."
            code = .internal
            invalidFields = nil
        case .networkUnreachable:
            message = "Request can't be processed because there is no network connection."
            code = .networkUnreachable
            invalidFields = nil
        case .timeout:
            message = "Request timed out."
            code = .timeout
            invalidFields = nil
        case .cancelled:
            message = "Request was cancelled."
            code = .cancelled
            invalidFields = nil
        case let .server(error, statusCode):
            code = failureCode(from: error, statusCode: statusCode)
            message = error.message
            invalidFields = error.invalidFields?.map { .init(name: $0.name, message: $0.message) }
        }
        return .init(message: message, code: code ?? .unknown, invalidFields: invalidFields, underlyingError: failure)
    }

    // MARK: - Private Methods

    private func failureCode(
        from error: HttpConnectorFailure.Server, statusCode: Int
    ) -> POFailure.Code? {
        switch statusCode {
        case 401:
            let authenticationCode = POFailure.AuthenticationCode(rawValue: error.errorType)
            return authenticationCode.map(POFailure.Code.authentication)
        case 404:
            let notFoundCode = POFailure.NotFoundCode(rawValue: error.errorType)
            return notFoundCode.map(POFailure.Code.notFound)
        case 400...499:
            if let validationCode = POFailure.ValidationCode(rawValue: error.errorType) {
                return POFailure.Code.validation(validationCode)
            }
            if let genericCode = POFailure.GenericCode(rawValue: error.errorType) {
                return POFailure.Code.generic(genericCode)
            }
        case 500...599:
            return .internal
        default:
            return nil
        }
        return nil
    }
}

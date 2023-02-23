//
//  HttpConnectorFailureMapper.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.10.2022.
//

import Foundation

final class HttpConnectorFailureMapper: HttpConnectorFailureMapperType {

    init(logger: POLogger) {
        self.logger = logger
    }

    // MARK: - HttpConnectorFailureMapperType

    func failure(from failure: HttpConnectorFailure) -> POFailure {
        let message: String?
        let code: POFailure.Code?
        let invalidFields: [POFailure.InvalidField]?
        switch failure {
        case .coding, .internal:
            message = "An unexpected error occurred while processing your request."
            code = .internal(.mobile)
            invalidFields = nil
        case .networkUnreachable:
            message = "Request can't be processed because there is no network connection."
            code = .networkUnreachable
            invalidFields = nil
        case .timeout:
            message = "Request timed out."
            code = .timeout(.mobile)
            invalidFields = nil
        case .cancelled:
            message = "Request was cancelled."
            code = .cancelled
            invalidFields = nil
        case let .server(error, statusCode):
            message = error.message
            code = failureCode(from: error, statusCode: statusCode)
            if code == nil {
                logger.info("Unknown error type '\(error.errorType)', code '\(statusCode)'")
            }
            invalidFields = error.invalidFields?.map { .init(name: $0.name, message: $0.message) }
        }
        let failure = POFailure(
            message: message, code: code ?? .unknown(.mobile), invalidFields: invalidFields, underlyingError: failure
        )
        return failure
    }

    // MARK: - Private Properties

    private let logger: POLogger

    // MARK: - Private Methods

    private func failureCode(from error: HttpConnectorFailure.Server, statusCode: Int) -> POFailure.Code? {
        switch statusCode {
        case 401:
            let authenticationCode = POFailure.AuthenticationCode(rawValue: error.errorType)
            return authenticationCode.map(POFailure.Code.authentication)
        case 404:
            let notFoundCode = POFailure.NotFoundCode(rawValue: error.errorType)
            return notFoundCode.map(POFailure.Code.notFound)
        case 400...499:
            if let validationCode = POFailure.ValidationCode(rawValue: error.errorType) {
                return .validation(validationCode)
            }
            if let genericCode = POFailure.GenericCode(rawValue: error.errorType) {
                return .generic(genericCode)
            }
            if let unknownCode = POFailure.UnknownCode(rawValue: error.errorType) {
                return .unknown(unknownCode)
            }
            if let internalCode = POFailure.InternalCode(rawValue: error.errorType) {
                return .internal(internalCode)
            }
            if let timeoutCode = POFailure.TimeoutCode(rawValue: error.errorType) {
                return .timeout(timeoutCode)
            }
        case 500...599:
            return .internal(.mobile)
        default:
            return nil
        }
        return nil
    }
}

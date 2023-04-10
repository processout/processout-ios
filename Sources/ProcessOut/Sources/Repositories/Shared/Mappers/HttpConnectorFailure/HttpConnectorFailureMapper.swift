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
        let message: String?
        let code: POFailure.Code
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
            invalidFields = error.invalidFields?.map { .init(name: $0.name, message: $0.message) }
        }
        let failure = POFailure(
            message: message, code: code, invalidFields: invalidFields, underlyingError: failure
        )
        return failure
    }

    // MARK: - Private Properties

    private let logger: POLogger

    // MARK: - Private Methods

    private func failureCode(from error: HttpConnectorFailure.Server, statusCode: Int) -> POFailure.Code {
        switch statusCode {
        case 401:
            if let code = POFailure.AuthenticationCode(rawValue: error.errorType) {
                return .authentication(code)
            }
        case 404:
            if let code = POFailure.NotFoundCode(rawValue: error.errorType) {
                return .notFound(code)
            }
        case 400...599:
            if let code = POFailure.ValidationCode(rawValue: error.errorType) {
                return .validation(code)
            }
            if let code = POFailure.GenericCode(rawValue: error.errorType) {
                return .generic(code)
            }
            if let code = POFailure.TimeoutCode(rawValue: error.errorType) {
                return .timeout(code)
            }
            if let code = POFailure.InternalCode(rawValue: error.errorType) {
                return .internal(code)
            }
        default:
            break
        }
        return .unknown(rawValue: error.errorType)
    }
}

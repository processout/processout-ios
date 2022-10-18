//
//  RepositoryFailureFactory.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.10.2022.
//

import Foundation

final class RepositoryFailureFactory: RepositoryFailureFactoryType {

    func repositoryFailure(from failure: HttpConnectorFailure) -> PORepositoryFailure {
        let message: String?
        let code: PORepositoryFailure.Code?
        switch failure {
        case .coding, .cancelled, .internal:
            message = "An unexpected error occurred while processing your request."
            code = .internal
        case .networkUnreachable:
            message = nil
            code = .networkUnreachable
        case let .server(error, statusCode):
            switch statusCode {
            case 401:
                let authenticationCode = PORepositoryFailure.AuthenticationCode(rawValue: error.errorType)
                code = authenticationCode.map(PORepositoryFailure.Code.authentication)
            case 404:
                let notFoundCode = PORepositoryFailure.NotFoundCode(rawValue: error.errorType)
                code = notFoundCode.map(PORepositoryFailure.Code.notFound)
            case 400...499:
                if let validationCode = PORepositoryFailure.ValidationCode(rawValue: error.errorType) {
                    code = PORepositoryFailure.Code.validation(validationCode)
                } else if let genericCode = PORepositoryFailure.GenericCode(rawValue: error.errorType) {
                    code = PORepositoryFailure.Code.generic(genericCode)
                } else {
                    code = nil
                }
            case 500...599:
                code = .internal
            default:
                code = nil
            }
            message = error.message
        }
        return .init(message: message, code: code ?? .unknown, underlyingError: failure)
    }
}

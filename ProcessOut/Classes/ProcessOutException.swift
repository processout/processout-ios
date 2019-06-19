//
//  ProcessOutException.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 17/06/2019.
//

public enum ProcessOutException: Error {
    case NetworkError
    case MissingProjectId
    case BadRequest(errorMessage: String, errorCode: String)
    case InternalError
    case GenericError(error: Error)
}

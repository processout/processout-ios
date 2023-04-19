//
//  ProcessOutException.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 17/06/2019.
//

@available(*, deprecated, message: "Use POFailure instead.")
public enum ProcessOutException: Error {
    case NetworkError
    case MissingProjectId
    case BadRequest(errorMessage: String, errorCode: String)
    case InternalError
    case GenericError(error: Error)
}

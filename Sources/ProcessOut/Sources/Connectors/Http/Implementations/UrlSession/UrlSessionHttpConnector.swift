//
//  UrlSessionHttpConnector.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

import Foundation
import UIKit.UIDevice

final class UrlSessionHttpConnector: HttpConnector {

    init(
        sessionConfiguration: URLSessionConfiguration,
        requestMapper: HttpConnectorRequestMapper,
        decoder: JSONDecoder,
        logger: POLogger
    ) {
        self.requestMapper = requestMapper
        self.session = URLSession(configuration: sessionConfiguration)
        self.decoder = decoder
        self.logger = logger
        workQueue = DispatchQueue(label: "process-out.http-connector", attributes: .concurrent)
        urlRequestFormatter = UrlRequestFormatter()
        urlResponseFormatter = UrlResponseFormatter(includesHeaders: false)
    }

    // MARK: - HttpConnectorType

    func execute<Value>(
        request: HttpConnectorRequest<Value>, completion: @escaping (Result<Value, Failure>) -> Void
    ) -> POCancellable {
        let cancellable = GroupCancellable()
        workQueue.async { [self] in
            do {
                let sessionRequest = try requestMapper.urlRequest(from: request)
                logger.debug("Sending \(urlRequestFormatter.string(from: sessionRequest))")
                let dataTask = session.dataTask(with: sessionRequest) { [self] data, response, error in
                    do {
                        let value = try decodeValue(
                            Value.self, from: data, response: response, error: error, requestId: request.id
                        )
                        complete(completion: completion, result: .success(value))
                    } catch {
                        complete(completion: completion, result: .failure(error))
                    }
                }
                dataTask.resume()
                cancellable.add(dataTask)
            } catch {
                logger.error("Did fail to create a request: '\(error)'")
                complete(completion: completion, result: .failure(error))
            }
        }
        return cancellable
    }

    // MARK: - Private Properties

    private let session: URLSession
    private let requestMapper: HttpConnectorRequestMapper
    private let decoder: JSONDecoder
    private let workQueue: DispatchQueue
    private let logger: POLogger
    private let urlRequestFormatter: UrlRequestFormatter
    private let urlResponseFormatter: UrlResponseFormatter

    // MARK: - Private Methods

    private func decodeValue<Value: Decodable>(
        _ valueType: Value.Type, from data: Data?, response: URLResponse?, error: Error?, requestId: String
    ) throws -> Value {
        if let error {
            logger.info("Request \(requestId) did fail with error: '\(error)'.")
            throw convertToFailure(urlError: error)
        }
        guard let data, let response = response as? HTTPURLResponse else {
            logger.error("Invalid url response for \(requestId).")
            throw Failure.internal
        }
        let responseDescription = urlResponseFormatter.string(from: response, data: data)
        logger.debug("Received response for \(requestId): \(responseDescription)")
        do {
            if try decoder.decode(Response.self, from: data).success {
                return try decoder.decode(Value.self, from: data)
            }
            let failure = Failure.server(
                try decoder.decode(HttpConnectorFailure.Server.self, from: data), statusCode: response.statusCode
            )
            throw failure
        } catch let error as DecodingError {
            logger.error("Did fail to decode response for \(requestId): '\(error)'.")
            throw Failure.decoding(error, statusCode: response.statusCode)
        }
    }

    private func complete<Value>(completion: @escaping (Result<Value, Failure>) -> Void, result: Result<Value, Error>) {
        let result = result.mapError { error -> Failure in
            if let failure = error as? Failure {
                return failure
            }
            logger.error("Attempted to complete request with unknown error: \(error)")
            return .internal
        }
        DispatchQueue.main.async { completion(result) }
    }

    private func convertToFailure(urlError error: Error) -> Failure {
        switch error {
        case URLError.cancelled:
            return .cancelled
        case URLError.notConnectedToInternet, URLError.networkConnectionLost:
            return .networkUnreachable
        case URLError.timedOut:
            return .timeout
        default:
            return .internal
        }
    }
}

private struct Response: Decodable {

    /// Indicates whether request was processed successfuly.
    let success: Bool
}

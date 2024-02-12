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
        urlRequestFormatter = UrlRequestFormatter()
        urlResponseFormatter = UrlResponseFormatter(includesHeaders: false)
    }

    // MARK: - HttpConnector

    func configure(configuration: HttpConnectorRequestMapperConfiguration) {
        requestMapper.configure(configuration: configuration)
    }

    func execute<Value>(request: HttpConnectorRequest<Value>) async throws -> Value {
        let sessionRequest = try await requestMapper.urlRequest(from: request)
        logger.debug("Sending \(urlRequestFormatter.string(from: sessionRequest))")
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: sessionRequest)
        } catch let error as URLError {
            logger.info("Request \(request.id) did fail with error: '\(error)'.")
            throw convertToFailure(urlError: error)
        } catch {
            logger.info("Request \(request.id) did fail with unknown error '\(error)'.")
            throw Failure.internal
        }
        return try decodeValue(Value.self, from: data, response: response, requestId: request.id)
    }

    // MARK: - Private Properties

    private let session: URLSession
    private let requestMapper: HttpConnectorRequestMapper
    private let decoder: JSONDecoder
    private let logger: POLogger
    private let urlRequestFormatter: UrlRequestFormatter
    private let urlResponseFormatter: UrlResponseFormatter

    // MARK: - Private Methods

    private func decodeValue<Value: Decodable>(
        _ valueType: Value.Type, from data: Data, response: URLResponse, requestId: String
    ) throws -> Value {
        guard let response = response as? HTTPURLResponse else {
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
